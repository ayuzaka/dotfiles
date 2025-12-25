local find_vue_typescript_plugin_path = function()
  local pattern = vim.fn.expand("~/.local/share/mise/installs/npm-vue-language-server/*/node_modules/@vue/typescript-plugin")
  local matches = vim.fn.glob(pattern, false, true)
  if type(matches) == "table" and #matches > 0 then
    table.sort(matches)
    return matches[#matches]
  end

  return pattern
end

local vue_typescript_plugin_path = find_vue_typescript_plugin_path()
local tsserver_filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" }
local vue_plugin = {
  name = "@vue/typescript-plugin",
  location = vue_typescript_plugin_path,
  languages = { "vue" },
  configNamespace = "typescript",
}
local vtsls_config = {
  settings = {
    vtsls = {
      tsserver = {
        globalPlugins = {
          vue_plugin,
        },
      },
    },
  },
  filetypes = tsserver_filetypes,
}

return vtsls_config
