local find_typescript_server_path = function(root_dir)
  if root_dir then
    local tsdk = root_dir .. "/node_modules/typescript/lib"
    if vim.fn.isdirectory(tsdk) == 1 then
      return tsdk
    end
  end

  local base = vim.fn.expand("~/.local/share/mise/installs/npm-astrojs-language-server")
  if vim.fn.isdirectory(base) == 1 then
    local dirs = vim.fn.readdir(base)
    table.sort(dirs)
    for i = #dirs, 1, -1 do
      local tsdk = base .. "/" .. dirs[i] .. "/node_modules/typescript/lib"
      if vim.fn.isdirectory(tsdk) == 1 then
        return tsdk
      end
    end
  end

  return ""
end

return {
  init_options = {
    typescript = {},
  },
  before_init = function(_, config)
    if config.init_options and config.init_options.typescript and not config.init_options.typescript.tsdk then
      config.init_options.typescript.tsdk = find_typescript_server_path(config.root_dir)
    end
  end,
}