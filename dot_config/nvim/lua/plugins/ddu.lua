vim.api.nvim_create_autocmd("FileType", {
  pattern = "ddu-ff",
  callback = function()
    local opts = { buffer = true, silent = true }
    local keymaps = require("plugins.ddu-keymaps")
    keymaps.apply_common_normal(opts)

    vim.keymap.set("n", "<CR>", "<Cmd>call ddu#ui#do_action('itemAction')<CR>", opts)
    vim.keymap.set("n", "a", "<Cmd>call ddu#ui#do_action('itemAction', { 'name': 'add' })<CR>", opts)
    vim.keymap.set("n", "r", "<Cmd>call ddu#ui#do_action('itemAction', { 'name': 'reset' })<CR>", opts)
    vim.keymap.set("n", "i", "<Cmd>call ddu#ui#do_action('openFilterWindow')<CR>", opts)
    vim.keymap.set("n", "q", "<Cmd>call ddu#ui#do_action('quit')<CR>", opts)
    vim.keymap.set("n", "v", "<Cmd>call ddu#ui#do_action('itemAction', { 'name': 'markAsViewed' })<CR>", opts)
  end
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "ddu-ff-filter",
  callback = function()
    local opts = { buffer = true, silent = true }
    vim.keymap.set("i", "<CR>",
      "<Esc><Cmd>close<CR>", opts)
    vim.keymap.set("n", "<CR>",
      "<Cmd>close<CR>", opts)
    vim.keymap.set("n", "q",
      "<Cmd>close<CR>", opts)
  end
})

local vimx = require("artemis")
vimx.fn.ddu.custom.load_config(vimx.fn.expand("$XDG_CONFIG_HOME/nvim/ts/ddu.ts"))
