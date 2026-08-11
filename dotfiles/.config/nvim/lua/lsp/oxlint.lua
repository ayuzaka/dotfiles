local node_bin = require("lsp.node_bin")

local root_markers = { ".oxlintrc.json", ".oxlintrc.jsonc", "oxlint.config.ts" }

return {
  cmd = node_bin("oxlint", { "--lsp", "--type-aware" }),
  -- nvim-lspconfig's root_dir yields a relative "." for unnamed buffers, and the oxc
  -- server rejects that as an invalid workspace URI.
  root_dir = function(bufnr, on_dir)
    local root = vim.fs.root(bufnr, root_markers)
    if root then
      on_dir(root)
    end
  end,
}
