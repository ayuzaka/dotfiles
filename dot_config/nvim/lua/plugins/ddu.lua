vim.api.nvim_create_autocmd("FileType", {
  pattern = "ddu-ff",
  callback = function()
    local opts = { buffer = true, silent = true }
    vim.keymap.set("n", "<CR>",
      "<Cmd>call ddu#ui#do_action('itemAction')<CR>", opts)
    vim.keymap.set("n", "<Space>",
      "<Cmd>call ddu#ui#do_action('toggleSelectItem')<CR>", opts)
    vim.keymap.set("n", "i",
      "<Cmd>call ddu#ui#do_action('openFilterWindow')<CR>", opts)
    vim.keymap.set("n", "p",
      "<Cmd>call ddu#ui#do_action('preview')<CR>", opts)
    vim.keymap.set("n", "q",
      "<Cmd>call ddu#ui#do_action('quit')<CR>", opts)
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
