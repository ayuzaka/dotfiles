require("nvim-treesitter").setup({})

require'nvim-treesitter'.install {
  "astro", "bash", "css", "dockerfile", "fsharp", "git_config", "go", "graphql", "haskell", "html",
  "javascript", "json", "lua", "markdown", "python", "rust", "scss", "sql", "svelte", "toml", "typescript", "vim",
}

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("vim-treesitter-start", {}),
  callback = function()
    -- 必要に応じて`ctx.match`に入っているファイルタイプの値に応じて挙動を制御
    -- `pcall`でエラーを無視することでパーサーやクエリがあるか気にしなくてすむ
    pcall(vim.treesitter.start)
  end,
})

vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
