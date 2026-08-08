return {
  cmd = { "version-lsp" },
  filetypes = { "json", "jsonc", "toml", "gomod", "yaml" },
  root_markers = { ".git" },
  settings = {
    ["version-lsp"] = {
      cache = { refreshInterval = 86400000 },
      registries = {
        npm = { enabled = true },
        crates = { enabled = true },
        goProxy = { enabled = true },
        pypi = { enabled = true },
        github = { enabled = true },
        pnpmCatalog = { enabled = true },
        jsr = { enabled = true },
      },
      ignorePrerelease = true,
    },
  },
}
