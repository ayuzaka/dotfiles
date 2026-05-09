--- diffview.nvim のワークツリー（右側ペイン）に対して、GitHub PR 風の行コメント機能を提供するモジュール
--
-- 保存形式:
--   ~/.local/share/nvim/state/diffview_comments.json
--   { "git_toplevel": { "relative/path": { "line_number": "comment body" } } }
--
-- キーマップ（diffview の右側ペインのみ有効）:
--   gc  … カーソル行のコメントを追加・編集（空入力で削除）
--   gC  … カーソル行のコメントを floating window で表示
--       表示中に d … 削除 / e … 編集 / q, Esc … 閉じる
--
-- ファイルパネル表示:
--   コメントが付いているファイルの行末に " 💬" を表示

local M = {}

-- コメント JSON の保存先
local state_path = vim.fn.stdpath("state") .. "/diffview_comments.json"
-- diff バッファ（右側ペイン）の extmark namespace
local ns = vim.api.nvim_create_namespace("diffview_comments")
-- ファイルパネルバッファの extmark namespace
local panel_ns = vim.api.nvim_create_namespace("diffview_comments_panel")

-- ヘルパー: vim.notify のラッパー
local function notify(message, level)
  vim.notify(message, level or vim.log.levels.ERROR)
end

-- ───────────────────────────────────────────────────────────────
-- 永続化層
-- ───────────────────────────────────────────────────────────────

-- JSON ファイルから全コメントを読み込む
-- ファイルが存在しない・空・破損している場合は空テーブルを返す
local function read_comments()
  if vim.fn.filereadable(state_path) == 0 then
    return {}
  end

  local lines = vim.fn.readfile(state_path)
  if #lines == 0 then
    return {}
  end

  local ok, decoded = pcall(vim.json.decode, table.concat(lines, "\n"))
  if not ok or type(decoded) ~= "table" then
    notify("Failed to read diffview comments: " .. state_path)
    return {}
  end

  return decoded
end

-- JSON ファイルに全コメントを書き出す
-- 親ディレクトリが存在しない場合は自動作成
local function write_comments(data)
  vim.fn.mkdir(vim.fn.fnamemodify(state_path, ":h"), "p")

  local ok, encoded = pcall(vim.json.encode, data)
  if not ok then
    notify("Failed to encode diffview comments", vim.log.levels.ERROR)
    return false
  end

  local write_ok, err = pcall(vim.fn.writefile, vim.split(encoded, "\n"), state_path)
  if not write_ok then
    notify("Failed to save diffview comments: " .. err, vim.log.levels.ERROR)
    return false
  end

  return true
end

-- ───────────────────────────────────────────────────────────────
-- ファイルパネル表示（コメント付きファイルにインジケータを付与）
-- ───────────────────────────────────────────────────────────────

-- diffview のファイルパネルに " 💬" の virtual text を描画する
-- 各ファイルコンポーネントの行末に extmark でマーカーを表示
local function render_panel_indicators(panel)
  if not panel or not panel.bufid then
    return
  end
  local bufnr = panel.bufid
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end

  -- 既存の extmark をクリアしてから再描画
  vim.api.nvim_buf_clear_namespace(bufnr, panel_ns, 0, -1)

  local toplevel = panel.adapter.ctx.toplevel
  local data = read_comments()
  local repo = data[toplevel]
  if not repo then
    return
  end

  -- conflicting / working / staged の 3 セクションを走査
  local sections = {
    panel.components.conflicting.files,
    panel.components.working.files,
    panel.components.staged.files,
  }

  for _, section in ipairs(sections) do
    if section and section.comp then
      section.comp:deep_some(function(comp)
        if comp.name == "file" and comp.context and comp.context.path then
          if repo[comp.context.path] then
            pcall(vim.api.nvim_buf_set_extmark, bufnr, panel_ns, comp.lstart, 0, {
              virt_text = { { " 💬", "Comment" } },
              virt_text_pos = "eol",
              hl_mode = "combine",
            })
          end
        end
        return false
      end)
    end
  end
end

-- 現在アクティブな diffview のファイルパネルを再描画する
local function refresh_current_panel()
  local lib = require("diffview.lib")
  local DiffView = require("diffview.scene.views.diff.diff_view").DiffView
  local view = lib.get_current_view()
  if not view or not view:instanceof(DiffView) then
    return
  end
  ---@cast view DiffView
  render_panel_indicators(view.panel)
end

-- ───────────────────────────────────────────────────────────────
-- CRUD
-- ───────────────────────────────────────────────────────────────

-- コメントを追加・更新し、ファイルパネルインジケータを再描画する
local function set_comment(toplevel, relpath, line, body)
  local data = read_comments()
  data[toplevel] = data[toplevel] or {}
  data[toplevel][relpath] = data[toplevel][relpath] or {}
  data[toplevel][relpath][tostring(line)] = body
  write_comments(data)
  refresh_current_panel()
end

-- コメントを削除し、ファイルパネルインジケータを再描画する
-- ファイル・リポジトリが空になった場合はキーを掃除する
local function delete_comment(toplevel, relpath, line)
  local data = read_comments()
  if not data[toplevel] then
    return
  end
  if not data[toplevel][relpath] then
    return
  end
  data[toplevel][relpath][tostring(line)] = nil

  if vim.tbl_isempty(data[toplevel][relpath]) then
    data[toplevel][relpath] = nil
  end
  if vim.tbl_isempty(data[toplevel]) then
    data[toplevel] = nil
  end

  write_comments(data)
  refresh_current_panel()
end

-- ───────────────────────────────────────────────────────────────
-- diff バッファ表示（行末にコメント本文の要約を表示）
-- ───────────────────────────────────────────────────────────────

-- 指定バッファにコメントの virtual text を描画する
-- 複数行コメントの場合は "..." を付けて省略表示
local function render_comments(bufnr, toplevel, relpath)
  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

  local data = read_comments()
  local repo = data[toplevel]
  if not repo then
    return
  end
  local file = repo[relpath]
  if not file then
    return
  end

  for line_str, comment in pairs(file) do
    local lnum = tonumber(line_str)
    if lnum then
      local lines = vim.split(comment, "\n")
      local display = lines[1]
      if #lines > 1 then
        display = display .. " ..."
      end
      pcall(vim.api.nvim_buf_set_extmark, bufnr, ns, lnum - 1, 0, {
        virt_text = { { "💬 " .. display, "Comment" } },
        virt_text_pos = "eol",
        hl_mode = "combine",
      })
    end
  end
end

-- ───────────────────────────────────────────────────────────────
-- コンテキスト取得
-- ───────────────────────────────────────────────────────────────

-- 現在の diffview 右ペイン（ワークツリー）の情報を取得する
-- diffview 外・左ペイン・FileHistoryView などの場合は nil を返す
local function get_current_info()
  local lib = require("diffview.lib")
  local DiffView = require("diffview.scene.views.diff.diff_view").DiffView
  local RevType = require("diffview.vcs.rev").RevType

  local view = lib.get_current_view()
  if not view then
    return nil
  end
  if not view:instanceof(DiffView) then
    return nil
  end
  ---@cast view DiffView

  local layout = view.cur_layout
  ---@cast layout Diff2
  if not layout or not layout.b then
    return nil
  end
  local file = layout.b.file
  if not file or file.rev.type ~= RevType.LOCAL then
    return nil
  end

  return {
    toplevel = view.adapter.ctx.toplevel,
    relpath = file.path,
    bufnr = file.bufnr,
  }
end

-- ───────────────────────────────────────────────────────────────
-- ユーザーインターフェース
-- ───────────────────────────────────────────────────────────────

-- gc: コメントの追加・編集・削除
-- 既存コメントがあれば default 値に設定し、空入力で削除する
local function edit_comment()
  local info = get_current_info()
  if not info then
    vim.notify("Not in a diffview right pane", vim.log.levels.WARN)
    return
  end

  local row = vim.api.nvim_win_get_cursor(0)[1]
  local data = read_comments()
  local repo = data[info.toplevel] or {}
  local file = repo[info.relpath] or {}
  local existing = file[tostring(row)] or ""

  vim.ui.input({
    prompt = "Comment: ",
    default = existing,
  }, function(input)
    if input == nil then
      return
    end
    local trimmed = vim.trim(input)
    if trimmed == "" then
      delete_comment(info.toplevel, info.relpath, row)
    else
      set_comment(info.toplevel, info.relpath, row, trimmed)
    end
    render_comments(info.bufnr, info.toplevel, info.relpath)
  end)
end

-- gC: コメントの詳細表示（floating window）
-- 表示中に d（削除）/ e（編集）/ q, Esc（閉じる）が使える
local function show_comment()
  local info = get_current_info()
  if not info then
    vim.notify("Not in a diffview right pane", vim.log.levels.WARN)
    return
  end

  local row = vim.api.nvim_win_get_cursor(0)[1]
  local data = read_comments()
  local repo = data[info.toplevel] or {}
  local file = repo[info.relpath] or {}
  local comment = file[tostring(row)]

  if not comment then
    vim.notify("No comment on this line", vim.log.levels.INFO)
    return
  end

  local lines = vim.split(comment, "\n")
  local width = 0
  for _, line in ipairs(lines) do
    width = math.max(width, vim.fn.strdisplaywidth(line))
  end

  local float_buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(float_buf, true, {
    border = "rounded",
    col = 1,
    height = #lines,
    relative = "cursor",
    row = 1,
    style = "minimal",
    width = width,
  })

  vim.api.nvim_buf_set_lines(float_buf, 0, -1, false, lines)
  vim.bo[float_buf].modifiable = false

  local function close()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end

  vim.keymap.set("n", "q", close, { buffer = float_buf, silent = true })
  vim.keymap.set("n", "<Esc>", close, { buffer = float_buf, silent = true })
  vim.keymap.set("n", "d", function()
    delete_comment(info.toplevel, info.relpath, row)
    render_comments(info.bufnr, info.toplevel, info.relpath)
    close()
  end, { buffer = float_buf, silent = true })
  vim.keymap.set("n", "e", function()
    close()
    vim.schedule(function()
      edit_comment()
    end)
  end, { buffer = float_buf, silent = true })

  vim.api.nvim_create_autocmd("BufLeave", {
    buffer = float_buf,
    once = true,
    callback = close,
  })
end

-- ───────────────────────────────────────────────────────────────
-- セットアップ
-- ───────────────────────────────────────────────────────────────

-- diffview.nvim のイベントをフックしてコメント機能を有効化する
function M.setup()
  local ok = pcall(require, "diffview.lib")
  if not ok then
    return
  end

  local lib = require("diffview.lib")
  local DiffView = require("diffview.scene.views.diff.diff_view").DiffView
  local RevType = require("diffview.vcs.rev").RevType

  -- diffview の右ペイン（ワークツリー側）が開かれるたびに:
  --   1. 既存コメントの virtual text を描画
  --   2. gc / gC のバッファローカルキーマップを設定
  --
  -- diff_buf_win_enter のコールバックシグネチャ:
  --   function(event, bufnr, winid, ctx)
  -- ctx.symbol == "b" のみがワークツリー（右側）
  DiffviewGlobal.emitter:on("diff_buf_win_enter", function(_, bufnr, _winid, ctx)
    if not ctx or ctx.symbol ~= "b" then
      return
    end

    local view = lib.get_current_view()
    if not view or not view:instanceof(DiffView) then
      return
    end
    ---@cast view DiffView

    local layout = view.cur_layout
    ---@cast layout Diff2
    if not layout or not layout.b then
      return
    end
    local file = layout.b.file
    if not file or file.rev.type ~= RevType.LOCAL then
      return
    end

    local toplevel = view.adapter.ctx.toplevel
    local relpath = file.path

    render_comments(bufnr, toplevel, relpath)

    vim.keymap.set("n", "gc", edit_comment, { buffer = bufnr, silent = true })
    vim.keymap.set("n", "gC", show_comment, { buffer = bufnr, silent = true })
  end)

  -- ファイルパネル（左側のファイル一覧）のバッファ変更を監視し、
  -- コメント付きファイルに " 💬" のインジケータを描画する
  local panel_group = vim.api.nvim_create_augroup("DiffviewCommentsPanel", { clear = true })
  vim.api.nvim_create_autocmd("FileType", {
    group = panel_group,
    pattern = "DiffviewFiles",
    callback = function(args)
      local bufnr = args.buf
      vim.api.nvim_buf_attach(bufnr, false, {
        on_lines = function()
          -- パネル内容の再描画後にインジケータを付け直す
          vim.schedule(function()
            if not vim.api.nvim_buf_is_valid(bufnr) then
              return
            end
            local view = lib.get_current_view()
            if view and view:instanceof(DiffView) then
              ---@cast view DiffView
              if view.panel and view.panel.bufid == bufnr then
                render_panel_indicators(view.panel)
              end
            end
          end)
        end,
      })
    end,
  })
end

return M
