vim.lsp.config("sqls", {})
vim.lsp.enable("sqls")

vim.api.nvim_create_autocmd("User", {
  pattern = "SqlsConnectionChoice",
  callback = function(args)
    local choice = args.data and args.data.choice
    vim.g.sqls_current_connection = choice and vim.split(choice, " ")[3]
  end,
})

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
