--- 行コメントの UI 機能（extmark 描画・floating window）
-- diffview に依存しない純粋な UI 層

local M = {}

local core = require("config.comments_core")

-- extmark namespace（diff バッファ・通常バッファ用）
local ns = vim.api.nvim_create_namespace("comments")
-- ファイルパネル・インジケータ用 namespace
local panel_ns = vim.api.nvim_create_namespace("comments_panel")

-- ───────────────────────────────────────────────────────────────
-- extmark 描画（バッファ用）
-- ───────────────────────────────────────────────────────────────

-- 指定バッファにコメントの virtual text を描画する
-- 複数行コメントの場合は "..." を付けて省略表示
function M.render_comments(bufnr, toplevel, relpath)
  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

  local file = core.get_comments(toplevel, relpath)
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
-- インジケータ描画（ファイルパネル・ジェネリック）
-- ───────────────────────────────────────────────────────────────

-- entries: { { lnum = 0-based, path = "relative/path" }, ... }
-- toplevel と relpaths でマッチした行に " 💬" を描画する
function M.render_indicators(bufnr, entries, toplevel)
  vim.api.nvim_buf_clear_namespace(bufnr, panel_ns, 0, -1)

  local repo = core.get_comments(toplevel)
  if not repo then
    return
  end

  for _, entry in ipairs(entries) do
    if repo[entry.path] then
      pcall(vim.api.nvim_buf_set_extmark, bufnr, panel_ns, entry.lnum, 0, {
        virt_text = { { " 💬", "Comment" } },
        virt_text_pos = "eol",
        hl_mode = "combine",
      })
    end
  end
end

-- ───────────────────────────────────────────────────────────────
-- Floating window エディタ
-- ───────────────────────────────────────────────────────────────

-- コメント編集用 floating window を開く
-- :wq で確定、:q でキャンセル
function M.show_comment_editor(toplevel, relpath, line, existing, callback)
  existing = existing or ""

  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].buftype = "acwrite"
  vim.bo[buf].swapfile = false

  local lines = existing ~= "" and vim.split(existing, "\n") or { "" }
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  local width = math.min(80, vim.o.columns - 4)
  local height = math.min(20, vim.o.lines - 4)

  local win = vim.api.nvim_open_win(buf, true, {
    border = "rounded",
    col = math.floor((vim.o.columns - width) / 2),
    height = height,
    noautocmd = true,
    relative = "editor",
    row = math.floor((vim.o.lines - height) / 2),
    style = "minimal",
    width = width,
  })

  -- バッファ名を comment:// プロトコル形式ではなく単純な名前に変更
  vim.api.nvim_buf_set_name(buf, "[comment] " .. relpath .. ":" .. line)

  vim.cmd("startinsert")

  local function close()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
    if vim.api.nvim_buf_is_valid(buf) then
      vim.api.nvim_buf_delete(buf, { force = true })
    end
  end

  local function confirm()
    local new_lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    local body = vim.trim(table.concat(new_lines, "\n"))
    close()
    if callback then
      callback(body)
    end
  end

  vim.api.nvim_create_autocmd("BufWriteCmd", {
    buffer = buf,
    callback = function()
      local new_lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
      local body = vim.trim(table.concat(new_lines, "\n"))
      vim.bo[buf].modified = false
      if callback then
        callback(body)
      end
    end,
  })

  vim.api.nvim_create_autocmd("BufLeave", {
    buffer = buf,
    once = true,
    callback = close,
  })

  vim.keymap.set("n", "q", function()
    close()
  end, { buffer = buf, silent = true })
end

-- ───────────────────────────────────────────────────────────────
-- Floating window 詳細表示
-- ───────────────────────────────────────────────────────────────

-- コメント詳細を floating window で表示
-- 表示中に d（削除）/ e（編集）/ q, Esc（閉じる）が使える
function M.show_comment_detail(toplevel, relpath, line, on_edit, on_delete)
  local file = core.get_comments(toplevel, relpath)
  local comment = file and file[tostring(line)]

  if not comment then
    vim.notify("No comment on this line", vim.log.levels.INFO)
    return
  end

  local lines = vim.split(comment, "\n")
  local width = 0
  for _, l in ipairs(lines) do
    width = math.max(width, vim.fn.strdisplaywidth(l))
  end
  width = math.min(width, vim.o.columns - 4)

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
    if vim.api.nvim_buf_is_valid(float_buf) then
      vim.api.nvim_buf_delete(float_buf, { force = true })
    end
  end

  vim.keymap.set("n", "q", close, { buffer = float_buf, silent = true })
  vim.keymap.set("n", "<Esc>", close, { buffer = float_buf, silent = true })

  if on_delete then
    vim.keymap.set("n", "d", function()
      close()
      on_delete()
    end, { buffer = float_buf, silent = true })
  end

  if on_edit then
    vim.keymap.set("n", "e", function()
      close()
      vim.schedule(on_edit)
    end, { buffer = float_buf, silent = true })
  end

  vim.api.nvim_create_autocmd("BufLeave", {
    buffer = float_buf,
    once = true,
    callback = close,
  })
end

return M
