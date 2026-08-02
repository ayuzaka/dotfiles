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
  file_panel = {
    win_config = {
      position = "left",
    },
  },
  keymaps = {
    view = {
      { "n", "gf",         goto_file_and_close },
      { "n", "<C-w><C-f>", false },
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

local function diff_with_base()
  local branch = vim.fn.system("detect-best-branch.sh"):gsub("%s+", "")
  if vim.v.shell_error ~= 0 or branch == "" then
    vim.notify("Base branch not found", vim.log.levels.WARN)
    return
  end
  vim.cmd("DiffviewOpen " .. branch .. "...HEAD")
end

vim.keymap.set("n", "<leader>do", "<cmd>DiffviewOpen<CR>", { desc = "DiffviewOpen" })
vim.keymap.set("n", "<leader>dq", "<cmd>DiffviewClose<CR>", { desc = "DiffviewClose" })
vim.keymap.set("n", "<leader>db", diff_with_base, { desc = "Diff with base branch" })
vim.keymap.set("n", "<leader>df", "<cmd>DiffviewFileHistory %<CR>", { desc = "Diffview Log" })
vim.keymap.set("n", "<leader>dl", "<cmd>DiffviewFileHistory<CR>", { desc = "DiffviewFileHistory" })
