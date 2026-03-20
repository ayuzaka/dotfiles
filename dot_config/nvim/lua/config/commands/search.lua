local utils = require("lib.utils")

local function open_search(provider, opts)
  local search_query = utils.resolve_search_query(opts, { prompt = provider.prompt })

  if search_query == nil then
    return
  end

  vim.ui.open(provider.build_url(search_query))
end

local search_providers = {
  DuckDuckGoSearch = {
    build_url = function(search_query)
      return "https://duckduckgo.com/?q=" .. utils.url_encode(search_query)
    end,
    prompt = "Search DuckDuckGo: ",
  },
  GitHubRepoSearch = {
    build_url = function(search_query)
      return "https://github.com/search?q=" .. utils.url_encode(search_query) .. "&type=repositories"
    end,
    prompt = "Search repositories: ",
  },
  GoogleSearch = {
    build_url = function(search_query)
      return "https://www.google.com/search?q=" .. utils.url_encode(search_query)
    end,
    prompt = "search google: ",
  },
  NpmxSearch = {
    build_url = function(search_query)
      return "https://npmx.dev/search?q=" .. utils.url_encode(search_query)
    end,
    prompt = "search NPM: ",
  },
  RfcTitleSearch = {
    build_url = function(search_query)
      return "https://www.rfc-editor.org/search/rfc_search_detail.php?title=" .. utils.url_encode(search_query)
    end,
    prompt = "search RFC title: ",
  },
  RfcNumberSearch = {
    build_url = function(search_query)
      return "https://www.rfc-editor.org/search/rfc_search_detail.php?rfc=" .. utils.url_encode(search_query)
    end,
    prompt = "search RFC number: ",
  },
}

for command_name, provider in pairs(search_providers) do
  vim.api.nvim_create_user_command(command_name, function(opts)
    open_search(provider, opts)
  end, { nargs = "*", range = true })
end
