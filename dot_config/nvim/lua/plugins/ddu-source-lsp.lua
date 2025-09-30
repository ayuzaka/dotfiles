vim.g.ddu_source_lsp_clientName = "nvim-lsp"

vim.keymap.set("n", "<C-d>d", function()
  vim.fn["ddu#start"]({ name = "lsp_definition" })
end, { silent = true })

vim.keymap.set("n", "<C-d>t", function()
  vim.fn["ddu#start"]({ name = "lsp_typeDefinition" })
end, { silent = true })

vim.keymap.set("n", "<C-d>i", function()
  vim.fn["ddu#start"]({ name = "lsp_implementation" })
end, { silent = true })

vim.keymap.set("n", "<C-d>r", function()
  vim.fn["ddu#start"]({ name = "lsp_references" })
end, { silent = true })
