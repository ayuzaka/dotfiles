local utils = require("config.utils")

local function open_search(provider, opts)
  local search_query = utils.resolve_search_query(opts, { prompt = provider.prompt })

  if search_query == nil then
    return
  end

  vim.ui.open(provider.build_url(search_query))
end

local function open_search_in_buffer(provider, command_name)
  local buf = vim.api.nvim_create_buf(false, true)

  vim.api.nvim_buf_set_name(buf, command_name .. "://ask")
  vim.api.nvim_set_option_value("buftype", "", { buf = buf })
  vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = buf })
  vim.api.nvim_set_option_value("swapfile", false, { buf = buf })

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
    "# " .. provider.prompt,
    "# 入力後、:w で保存して :q で送信",
    "",
    "",
  })

  vim.api.nvim_create_autocmd("BufWriteCmd", {
    buffer = buf,
    callback = function()
      vim.api.nvim_set_option_value("modified", false, { buf = buf })
    end,
  })

  vim.api.nvim_create_autocmd("BufWinLeave", {
    buffer = buf,
    once = true,
    callback = function()
      local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
      local query_parts = {}
      for _, line in ipairs(lines) do
        if not line:match("^#") and line:match("%S") then
          table.insert(query_parts, line)
        end
      end
      local query = table.concat(query_parts, "\n")
      if query ~= "" then
        vim.ui.open(provider.build_url(query))
      end
    end,
  })

  vim.cmd("split")
  vim.api.nvim_win_set_buf(0, buf)
  vim.api.nvim_win_set_cursor(0, { 4, 0 })
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
  ChatGPTAsk = {
    build_url = function(search_query)
      return "https://chatgpt.com?q=" .. utils.url_encode(search_query)
    end,
    prompt = "Ask ChatGPT: ",
    use_buffer = true,
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
  XSearch = {
    build_url = function(search_query)
      return "https://x.com/search?q=" .. utils.url_encode(search_query)
    end,
    prompt = "search X search: ",
  },
}

for command_name, provider in pairs(search_providers) do
  vim.api.nvim_create_user_command(command_name, function(opts)
    if provider.use_buffer then
      open_search_in_buffer(provider, command_name)
    else
      open_search(provider, opts)
    end
  end, { nargs = "*", range = true })
end
