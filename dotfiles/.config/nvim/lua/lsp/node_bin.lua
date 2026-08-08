-- Neovim spawns the server with cwd = root_dir, and in a hoisted pnpm workspace the
-- per-package root_dir has no node_modules/.bin, so the binary is searched upward.
local function resolve(name, root_dir)
  local dir = root_dir
  while dir do
    local candidate = vim.fs.joinpath(dir, "node_modules", ".bin", name)
    if vim.fn.executable(candidate) == 1 then
      return candidate
    end
    local parent = vim.fs.dirname(dir)
    dir = parent ~= dir and parent or nil
  end
  return name
end

return function(name, args)
  return function(dispatchers, config)
    local exe = resolve(name, (config or {}).root_dir)
    return vim.lsp.rpc.start(vim.list_extend({ exe }, args), dispatchers)
  end
end
