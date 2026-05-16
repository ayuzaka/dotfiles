--- diffview.nvim 連携アダプタ
-- diffview 専用知識のみを持ち、core/ui を利用する

local M = {}

local core = require("config.comments_core")
local ui = require("config.comments_ui")

-- 現在アクティブな diffview のファイルパネルを再描画する
local function refresh_current_panel()
  local lib = require("diffview.lib")
  local DiffView = require("diffview.scene.views.diff.diff_view").DiffView
  local view = lib.get_current_view()
  if not view or not view:instanceof(DiffView) then
    return
  end
  ---@cast view DiffView

  local panel = view.panel
  if not panel or not panel.bufid then
    return
  end
  local bufnr = panel.bufid
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end

  local toplevel = panel.adapter.ctx.toplevel

  -- パネルの各行に対応するファイルパスを収集
  local entries = {}

  local sections = {
    panel.components.conflicting.files,
    panel.components.working.files,
    panel.components.staged.files,
  }

  for _, section in ipairs(sections) do
    if section and section.comp then
      section.comp:deep_some(function(comp)
        if comp.name == "file" and comp.context and comp.context.path then
          table.insert(entries, {
            lnum = comp.lstart,
            path = comp.context.path,
          })
        end
        return false
      end)
    end
  end

  ui.render_indicators(bufnr, entries, toplevel)
end

-- コメント追加・更新後の再描画ハンドラ
local function after_update(toplevel, relpath, bufnr)
  ui.render_comments(bufnr, toplevel, relpath)
  refresh_current_panel()
end

-- gc: コメントの追加・編集・削除
local function edit_comment()
  local info = M.get_current_info()
  if not info then
    vim.notify("Not in a diffview right pane", vim.log.levels.WARN)
    return
  end

  local row = vim.api.nvim_win_get_cursor(0)[1]
  local file = core.get_comments(info.toplevel, info.relpath)
  local existing = file and file[tostring(row)] or ""

  ui.show_comment_editor(info.toplevel, info.relpath, row, existing, function(body)
    if body == "" then
      core.delete_comment(info.toplevel, info.relpath, row)
    else
      core.set_comment(info.toplevel, info.relpath, row, body)
    end
    after_update(info.toplevel, info.relpath, info.bufnr)
  end)
end

-- gC: コメントの詳細表示
local function show_comment()
  local info = M.get_current_info()
  if not info then
    vim.notify("Not in a diffview right pane", vim.log.levels.WARN)
    return
  end

  local row = vim.api.nvim_win_get_cursor(0)[1]
  local file = core.get_comments(info.toplevel, info.relpath)
  local comment = file and file[tostring(row)]

  if not comment then
    vim.notify("No comment on this line", vim.log.levels.INFO)
    return
  end

  ui.show_comment_detail(info.toplevel, info.relpath, row, function()
    vim.schedule(edit_comment)
  end, function()
    core.delete_comment(info.toplevel, info.relpath, row)
    after_update(info.toplevel, info.relpath, info.bufnr)
  end)
end

-- 現在の diffview ペインの情報を取得する
-- DiffView の右ペイン（b）または FileHistoryView の現在ファイルに対応
function M.get_current_info()
  local lib = require("diffview.lib")
  local DiffView = require("diffview.scene.views.diff.diff_view").DiffView
  local FileHistoryView = require("diffview.scene.views.file_history.file_history_view").FileHistoryView
  local RevType = require("diffview.vcs.rev").RevType

  local view = lib.get_current_view()
  if not view then
    return nil
  end

  local file
  local toplevel

  if view:instanceof(DiffView) then
    ---@cast view DiffView
    local layout = view.cur_layout
    ---@cast layout Diff2
    if not layout or not layout.b then
      return nil
    end
    file = layout.b.file
    if not file then
      return nil
    end
    local is_local = file.rev.type == RevType.LOCAL
    local is_commit = file.rev.type == RevType.COMMIT
    if not (is_local or is_commit) then
      return nil
    end
    toplevel = view.adapter.ctx.toplevel
  elseif view:instanceof(FileHistoryView) then
    ---@cast view FileHistoryView
    file = view:infer_cur_file()
    if not file then
      return nil
    end
    toplevel = view.adapter.ctx.toplevel
  else
    return nil
  end

  return {
    toplevel = toplevel,
    relpath = file.path,
    bufnr = vim.api.nvim_get_current_buf(),
  }
end

-- ───────────────────────────────────────────────────────────────
-- セットアップ
-- ───────────────────────────────────────────────────────────────

function M.setup()
  local ok = pcall(require, "diffview.lib")
  if not ok then
    return
  end

  local lib = require("diffview.lib")
  local DiffView = require("diffview.scene.views.diff.diff_view").DiffView
  local FileHistoryView = require("diffview.scene.views.file_history.file_history_view").FileHistoryView
  local RevType = require("diffview.vcs.rev").RevType

  -- diffview の diff バッファが開かれるたびに:
  --   1. 既存コメントの virtual text を描画
  --   2. gc / gC のバッファローカルキーマップを設定
  DiffviewGlobal.emitter:on("diff_buf_win_enter", function(_, bufnr, _winid, ctx)
    local view = lib.get_current_view()
    if not view then
      return
    end

    local toplevel
    local relpath

    if view:instanceof(DiffView) then
      ---@cast view DiffView
      if not ctx or ctx.symbol ~= "b" then
        return
      end

      local layout = view.cur_layout
      ---@cast layout Diff2
      if not layout or not layout.b then
        return
      end
      local file = layout.b.file
      if not file then
        return
      end
      local is_local = file.rev.type == RevType.LOCAL
      local is_commit = file.rev.type == RevType.COMMIT
      if not (is_local or is_commit) then
        return
      end

      toplevel = view.adapter.ctx.toplevel
      relpath = file.path
    elseif view:instanceof(FileHistoryView) then
      ---@cast view FileHistoryView
      local file = view:infer_cur_file()
      if not file then
        return
      end
      toplevel = view.adapter.ctx.toplevel
      relpath = file.path
    else
      return
    end

    ui.render_comments(bufnr, toplevel, relpath)

    vim.keymap.set("n", "gc", edit_comment, { buffer = bufnr, silent = true, nowait = true })
    vim.keymap.set("n", "gC", show_comment, { buffer = bufnr, silent = true, nowait = true })
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
          vim.schedule(function()
            if not vim.api.nvim_buf_is_valid(bufnr) then
              return
            end
            local view = lib.get_current_view()
            if view and view:instanceof(DiffView) then
              ---@cast view DiffView
              if view.panel and view.panel.bufid == bufnr then
                refresh_current_panel()
              end
            end
          end)
        end,
      })
    end,
  })
end

return M
