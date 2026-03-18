local utils = require("config.utils")

local function open_npmx(opts)
  local search_query = utils.resolve_search_query(opts, {
    empty_message = "Could not determine npm search query",
    get_fallback_query = function()
      local line = vim.api.nvim_get_current_line()
      local col = vim.api.nvim_win_get_cursor(0)[2] + 1
      return utils.get_quoted_text_under_cursor(line, col)
    end,
  })

  if not search_query then
    return
  end

  local url = "https://npmx.dev/" .. utils.url_encode(search_query)
  vim.ui.open(url)
end

local function open_npm_browser_command(subcommand, opts)
  local search_query = utils.resolve_search_query(opts, {
    empty_message = "Could not determine npm search query",
    get_fallback_query = function()
      local line = vim.api.nvim_get_current_line()
      local col = vim.api.nvim_win_get_cursor(0)[2] + 1
      return utils.get_quoted_text_under_cursor(line, col)
    end,
  })

  if not search_query then
    return
  end

  if vim.fn.executable("npm") ~= 1 then
    vim.notify("npm not found", vim.log.levels.ERROR)
    return
  end

  vim.fn.jobstart({ "npm", subcommand, search_query }, { detach = true })
end

local function get_latest_version(opts)
  local package_name = utils.resolve_search_query(opts, {
    empty_message = "Could not determine npm package name",
    get_fallback_query = function()
      local line = vim.api.nvim_get_current_line()
      local col = vim.api.nvim_win_get_cursor(0)[2] + 1
      return utils.get_quoted_text_under_cursor(line, col)
    end,
  })

  if not package_name then
    return
  end

  local result = {}
  vim.fn.jobstart({ "npm-package-latest-version", package_name }, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      for _, line in ipairs(data) do
        if line ~= "" then
          table.insert(result, line)
        end
      end
    end,
    on_exit = function(_, code)
      if code ~= 0 or #result == 0 then
        vim.notify("Failed to get latest version for: " .. package_name, vim.log.levels.ERROR)
        return
      end
      vim.notify(package_name .. "@" .. result[1], vim.log.levels.INFO)
    end,
  })
end

vim.api.nvim_create_user_command("NpmxDev", open_npmx, { range = true })
vim.api.nvim_create_user_command("NpmRepo", function(opts)
  open_npm_browser_command("repo", opts)
end, { range = true })
vim.api.nvim_create_user_command("NpmDocs", function(opts)
  open_npm_browser_command("docs", opts)
end, { range = true })
vim.api.nvim_create_user_command("NpmLatestVersion", get_latest_version, { range = true, nargs = "?" })
