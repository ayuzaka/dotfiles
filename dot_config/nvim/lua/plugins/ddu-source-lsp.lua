vim.g.ddu_source_lsp_clientName = "vim-lsp"

vim.fn["ddu#custom#patch_global"]({
    kindOptions = {
        lsp = {
            defaultAction = "open"
        },
        lsp_codeAction = {
            defaultAction = "apply"
        }
    }
})

vim.fn["ddu#custom#patch_local"]("lsp_definition", {
    sync = true,
    sources = {{
        name = "lsp_definition",
        params = {
            method = "textDocument/definition"
        }
    }}
})

vim.fn["ddu#custom#patch_local"]("lsp_references", {
    sync = true,
    sources = {{
        name = "lsp_references",
        params = {
            method = "textDocument/references",
            includeDeclaration = false
        }
    }}
})

vim.fn["ddu#custom#patch_local"]("codeAction", {
    sources = {{
        name = "lsp_codeAction",
        params = {
            method = "textDocument/codeAction"
        }
    }}
})

vim.fn["ddu#custom#patch_local"]("lsp_diagnostic", {
    sources = {{
        name = "lsp_diagnostic",
        params = {
            clientName = "nvim-lsp"
        }
    }}
})

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
