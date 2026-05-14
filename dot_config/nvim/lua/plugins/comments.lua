--- comments プラグイン設定
-- 通常バッファで gc/gC やユーザーコマンドを利用可能にする

local core = require("config.comments_core")
local ui = require("config.comments_ui")

-- カーソル行のコメントを追加・編集・削除
local function edit_comment()
  local bufnr = vim.api.nvim_get_current_buf()
  local abspath = vim.api.nvim_buf_get_name(bufnr)
  if abspath == "" then
    vim.notify("Buffer has no file name", vim.log.levels.WARN)
    return
  end

  local toplevel = core.get_toplevel_for_path(abspath)
  if not toplevel then
    vim.notify("Not inside a Git repository", vim.log.levels.WARN)
    return
  end

  local relpath = abspath:sub(#toplevel + 2)
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local file = core.get_comments(toplevel, relpath)
  local existing = file and file[tostring(row)] or ""

  ui.show_comment_editor(toplevel, relpath, row, existing, function(body)
    if body == "" then
      core.delete_comment(toplevel, relpath, row)
    else
      core.set_comment(toplevel, relpath, row, body)
    end
    ui.render_comments(bufnr, toplevel, relpath)
  end)
end

-- カーソル行のコメント詳細表示
local function show_comment()
  local bufnr = vim.api.nvim_get_current_buf()
  local abspath = vim.api.nvim_buf_get_name(bufnr)
  if abspath == "" then
    vim.notify("Buffer has no file name", vim.log.levels.WARN)
    return
  end

  local toplevel = core.get_toplevel_for_path(abspath)
  if not toplevel then
    vim.notify("Not inside a Git repository", vim.log.levels.WARN)
    return
  end

  local relpath = abspath:sub(#toplevel + 2)
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local file = core.get_comments(toplevel, relpath)
  local comment = file and file[tostring(row)]

  if not comment then
    vim.notify("No comment on this line", vim.log.levels.INFO)
    return
  end

  ui.show_comment_detail(toplevel, relpath, row, function()
    vim.schedule(edit_comment)
  end, function()
    core.delete_comment(toplevel, relpath, row)
    ui.render_comments(bufnr, toplevel, relpath)
  end)
end

-- カーソル行のコメント削除
local function delete_comment()
  local bufnr = vim.api.nvim_get_current_buf()
  local abspath = vim.api.nvim_buf_get_name(bufnr)
  if abspath == "" then
    vim.notify("Buffer has no file name", vim.log.levels.WARN)
    return
  end

  local toplevel = core.get_toplevel_for_path(abspath)
  if not toplevel then
    vim.notify("Not inside a Git repository", vim.log.levels.WARN)
    return
  end

  local relpath = abspath:sub(#toplevel + 2)
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local file = core.get_comments(toplevel, relpath)
  local comment = file and file[tostring(row)]

  if not comment then
    vim.notify("No comment on this line", vim.log.levels.INFO)
    return
  end

  core.delete_comment(toplevel, relpath, row)
  ui.render_comments(bufnr, toplevel, relpath)
end

-- 自動描画: バッファ読み込み・書き込み後に extmark を描画
local function auto_render()
  local bufnr = vim.api.nvim_get_current_buf()
  local abspath = vim.api.nvim_buf_get_name(bufnr)
  if abspath == "" then
    return
  end

  local toplevel = core.get_toplevel_for_path(abspath)
  if not toplevel then
    return
  end

  local relpath = abspath:sub(#toplevel + 2)
  ui.render_comments(bufnr, toplevel, relpath)
end

-- ユーザーコマンド定義
vim.api.nvim_create_user_command("CommentAdd", edit_comment, { desc = "Add/edit comment on current line" })
vim.api.nvim_create_user_command("CommentShow", show_comment, { desc = "Show comment on current line" })
vim.api.nvim_create_user_command("CommentDelete", delete_comment, { desc = "Delete comment on current line" })

-- グローバルキーマップ（全バッファ）
vim.keymap.set("n", "gc", edit_comment, { desc = "Add/edit comment" })
vim.keymap.set("n", "gC", show_comment, { desc = "Show comment" })

-- autocmd
local group = vim.api.nvim_create_augroup("CommentsAutoRender", { clear = true })
vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost" }, {
  group = group,
  callback = auto_render,
})
