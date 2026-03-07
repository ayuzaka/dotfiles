local utils = require("config.utils")

local function url_encode(value)
  return (value:gsub("([^%w%-_%.~])", function(char)
    return string.format("%%%02X", string.byte(char))
  end))
end

local function github_repo_search(opts)
  local search_query = ""

  if opts.range > 0 then
    search_query = utils.get_visual_query_text()
  else
    search_query = vim.trim(vim.fn.input("Search repositories: "))
  end

  if search_query == "" then
    vim.notify("Search query is empty", vim.log.levels.WARN)
    return
  end

  local url = "https://github.com/search?q=" .. url_encode(search_query) .. "&type=repositories"
  vim.ui.open(url)
end

vim.api.nvim_create_user_command("GitHubRepoSearch", github_repo_search, { range = true })
