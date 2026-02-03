vim.lsp.config("sqls", {})
vim.lsp.enable("sqls")

vim.keymap.set("v", "<leader>sq", "<Plug>(sqls-execute-query)", {
  silent = true,
  desc = "Execute SQL query (visual)",
})

vim.keymap.set("n", "<leader>sc", "<Cmd>SqlsSwitchConnection<CR>", {
  silent = true,
  desc = "Switch SQL connection",
})
