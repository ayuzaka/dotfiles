local utils = require("config.utils")

local function url_encode(value)
  return (value:gsub("([^%w%-_%.~])", function(char)
    return string.format("%%%02X", string.byte(char))
  end))
end

local function npm_search(opts)
  local search_query = ""

  if opts.range > 0 then
    search_query = utils.get_visual_query_text()
  else
    local line = vim.api.nvim_get_current_line()
    local col = vim.api.nvim_win_get_cursor(0)[2] + 1
    search_query = utils.get_quoted_text_under_cursor(line, col)
  end

  if not search_query or search_query == "" then
    vim.notify("Could not determine npm search query", vim.log.levels.WARN)
    return
  end

  local url = "https://npmx.dev/" .. url_encode(search_query)
  vim.ui.open(url)
end

vim.api.nvim_create_user_command("NpmSearch", npm_search, { range = true })
