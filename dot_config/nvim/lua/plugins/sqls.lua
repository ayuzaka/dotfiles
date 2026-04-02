vim.lsp.config("sqls", {})
vim.lsp.enable("sqls")

vim.api.nvim_create_autocmd("FileType", {
  pattern = "sql",
  callback = function(args)
    vim.keymap.set("v", "<leader>sq", "<Plug>(sqls-execute-query)", {
      buf = args.buf,
      silent = true,
      desc = "Execute SQL query (visual)",
    })

    vim.keymap.set("n", "<leader>sc", "<Cmd>SqlsSwitchConnection<CR>", {
      buf = args.buf,
      silent = true,
      desc = "Switch SQL connection",
    })
  end,
})
