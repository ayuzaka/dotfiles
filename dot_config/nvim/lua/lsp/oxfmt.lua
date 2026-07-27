local node_bin = require("lsp.node_bin")

local root_markers = { ".oxfmtrc.json", ".oxfmtrc.jsonc", "oxfmt.config.ts" }

return {
  cmd = node_bin("oxfmt", { "--lsp" }),
  filetypes = {
    "javascript",
    "javascriptreact",
    "javascript.jsx",
    "typescript",
    "typescriptreact",
    "typescript.tsx",
  },
  -- nvim-lspconfig's root_dir yields a relative "." for unnamed buffers, and the oxc
  -- server rejects that as an invalid workspace URI.
  root_dir = function(bufnr, on_dir)
    local root = vim.fs.root(bufnr, root_markers)
    if root then
      on_dir(root)
    end
  end,
}
