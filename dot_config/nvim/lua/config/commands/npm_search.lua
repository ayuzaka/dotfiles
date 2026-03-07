local utils = require("config.utils")

local function url_encode(value)
  return (value:gsub("([^%w%-_%.~])", function(char)
    return string.format("%%%02X", string.byte(char))
  end))
end

local function npm_search()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2] + 1
  local quoted_text = utils.get_quoted_text_under_cursor(line, col)
  if not quoted_text then
    vim.notify("Could not find quoted text under cursor", vim.log.levels.WARN)
    return
  end

  local url = "https://npmx.dev/" .. url_encode(quoted_text)
  vim.ui.open(url)
end

vim.api.nvim_create_user_command("NpmSearch", npm_search, {})
