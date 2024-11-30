vim.g.ddu_source_lsp_clientName = "vim-lsp"

vim.api.nvim_create_user_command("DduCodeAction", function()
    vim.fn["ddu#start"]({name = "codeAction"})
end, {})

vim.api.nvim_create_user_command("DduDef", function()
    vim.fn["ddu#start"]({name = "lsp_definition"})
end, {})

vim.api.nvim_create_user_command("DduRef", function()
    vim.fn["ddu#start"]({name = "lsp_references"})
end, {})

vim.api.nvim_create_user_command("DduDiagnostic", function()
    vim.fn["ddu#start"]({name = "lsp_diagnostic"})
end, {})

vim.keymap.set("n", "<C-d>d", function()
    vim.fn["ddu#start"]({name = "lsp_definition"})
end, {silent = true})

vim.keymap.set("n", "<C-d>r", function()
    vim.fn["ddu#start"]({name = "lsp_references"})
end, {silent = true})
