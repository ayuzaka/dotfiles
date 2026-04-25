local function open_commit_diffview()
  local lib = require("diffview.lib")
  local FileHistoryView = require("diffview.scene.views.file_history.file_history_view").FileHistoryView

  local view = lib.get_current_view()
  if not view or not view:instanceof(FileHistoryView) then return end
  ---@cast view FileHistoryView

  local commit
  if view.cur_entry then
    commit = view.cur_entry.commit
  end
  if not commit and view.panel then
    local item = view.panel:get_current_item()
    if item then commit = item.commit end
  end
  if not commit or not commit.hash then return end

  vim.cmd("DiffviewClose")
  vim.cmd("DiffviewOpen " .. commit.hash .. "^.." .. commit.hash)
end

local function goto_file_and_close()
  local lib = require("diffview.lib")
  local DiffView = require("diffview.scene.views.diff.diff_view").DiffView
  local FileHistoryView = require("diffview.scene.views.file_history.file_history_view").FileHistoryView

  local view = lib.get_current_view()
  if not view then return end
  if not (view:instanceof(DiffView) or view:instanceof(FileHistoryView)) then return end
  ---@cast view DiffView|FileHistoryView

  local file = view:infer_cur_file()
  if not file then return end

  local filepath = file.absolute_path
  local cursor
  if file == view.cur_entry then
    local win = view.cur_layout:get_main_win()
    cursor = vim.api.nvim_win_get_cursor(win.id)
  end

  vim.cmd("DiffviewClose")
  vim.cmd("edit " .. vim.fn.fnameescape(filepath))
  if cursor then
    vim.api.nvim_win_set_cursor(0, cursor)
  end
end

require("diffview").setup({
  keymaps = {
    view = {
      { "n", "gf",         goto_file_and_close },
      { "n", "<C-w><C-f>", false },
    },
    file_history_panel = {
      { "n", "<CR>", open_commit_diffview },
    },
    file_panel = {
      { "n", "g<C-x>",        false },
      { "n", "f",             false },
      { "n", "[F",            false },
      { "n", "]F",            false },
      { "n", "<tab>",         false },
      { "n", "<s-tab>",       false },
      { "n", "<2-LeftMouse>", false },
      { "n", "l",             false },
      { "n", "o",             false },
      { "n", "<c-f>",         false },
      { "n", "<c-b>",         false },
      { "n", "i",             false },
      { "n", "za",            false },
      { "n", "gf",            goto_file_and_close },
      { "n", "<C-w>gf",       false },
      { "n", "<C-w><C-f>",    false },
    },
  },
})

vim.keymap.set("n", "<leader>do", "<cmd>DiffviewOpen<CR>", { desc = "DiffviewOpen" })
vim.keymap.set("n", "<leader>dc", "<cmd>DiffviewClose<CR>", { desc = "DiffviewClose" })
vim.keymap.set("n", "<leader>db", "<cmd>DiffviewOpen origin/HEAD...HEAD<CR>", { desc = "Diff with base branch" })
