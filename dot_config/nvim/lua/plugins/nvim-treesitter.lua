require("nvim-treesitter").setup({})

require'nvim-treesitter'.install {
  "html", "css",
  "javascript", "typescript", "svelte", "vue", "astro",
  "go", "python", "rust", "fsharp", "haskell", "lua",
  "json", "toml", "yaml", "markdown", "git_config",
  "graphql", "dockerfile", "vim", "sql",
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
