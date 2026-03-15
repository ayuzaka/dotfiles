local utils = require("config.utils")

local function url_encode(value)
  return (value:gsub("([^%w%-_%.~])", function(char)
    return string.format("%%%02X", string.byte(char))
  end))
end

local function get_search_query(opts)
  local search_query

  if opts.range > 0 then
    search_query = utils.get_visual_query_text()
  else
    local line = vim.api.nvim_get_current_line()
    local col = vim.api.nvim_win_get_cursor(0)[2] + 1
    search_query = utils.get_quoted_text_under_cursor(line, col)
  end

  if not search_query or search_query == "" then
    vim.notify("Could not determine npm search query", vim.log.levels.WARN)
    return nil
  end

  return search_query
end

local function open_npmx(opts)
  local search_query = get_search_query(opts)
  if not search_query then
    return
  end

  local url = "https://npmx.dev/" .. url_encode(search_query)
  vim.ui.open(url)
end

local function open_npm_browser_command(subcommand, opts)
  local search_query = get_search_query(opts)
  if not search_query then
    return
  end

  if vim.fn.executable("npm") ~= 1 then
    vim.notify("npm not found", vim.log.levels.ERROR)
    return
  end

  vim.fn.jobstart({ "npm", subcommand, search_query }, { detach = true })
end

vim.api.nvim_create_user_command("NpmxDev", open_npmx, { range = true })
vim.api.nvim_create_user_command("NpmRepo", function(opts)
  open_npm_browser_command("repo", opts)
end, { range = true })
vim.api.nvim_create_user_command("NpmDocs", function(opts)
  open_npm_browser_command("docs", opts)
end, { range = true })
