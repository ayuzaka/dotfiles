local utils = require("lib.utils")

local function resolve_search_query(opts)
  return utils.resolve_search_query(opts, {
    empty_message = "Could not determine PyPI search query",
    get_fallback_query = function()
      local line = vim.api.nvim_get_current_line()
      local col = vim.api.nvim_win_get_cursor(0)[2] + 1
      return utils.get_quoted_text_under_cursor(line, col)
    end,
  })
end

local function open_pypi_project(opts)
  local search_query = resolve_search_query(opts)

  if not search_query then
    return
  end

  local url = "https://pypi.org/project/" .. utils.url_encode(search_query) .. "/"
  vim.ui.open(url)
end

local function normalize_project_url(project_url)
  if type(project_url) ~= "string" or project_url == "" then
    return nil
  end

  if vim.startswith(project_url, "http://") or vim.startswith(project_url, "https://") then
    return project_url
  end

  return nil
end

local function get_project_urls(info)
  local project_urls = {}

  if type(info.project_urls) == "table" then
    for label, url in pairs(info.project_urls) do
      if type(label) == "string" then
        project_urls[label:lower()] = normalize_project_url(url)
      end
    end
  end

  project_urls.home_page = normalize_project_url(info.home_page)
  project_urls.package_url = normalize_project_url(info.package_url)
  project_urls.project_url = normalize_project_url(info.project_url)

  return project_urls
end

local function find_project_url(project_urls, candidates)
  for _, candidate in ipairs(candidates) do
    local url = project_urls[candidate]
    if url then
      return url
    end
  end

  return nil
end

local function get_pypi_project_urls(package_name)
  local response = vim.fn.system({
    "curl",
    "--fail",
    "--location",
    "--silent",
    "https://pypi.org/pypi/" .. package_name .. "/json",
  })

  if vim.v.shell_error ~= 0 then
    return nil, "Failed to fetch PyPI package metadata"
  end

  local ok, payload = pcall(vim.json.decode, response)
  if not ok or type(payload) ~= "table" or type(payload.info) ~= "table" then
    return nil, "Failed to parse PyPI package metadata"
  end

  return get_project_urls(payload.info), nil
end

local function open_pypi_metadata_url(candidates, not_found_message, opts)
  local search_query = resolve_search_query(opts)

  if not search_query then
    return
  end

  local project_urls, error_message = get_pypi_project_urls(search_query)
  if error_message then
    vim.notify(error_message, vim.log.levels.ERROR)
    return
  end

  local url = find_project_url(project_urls, candidates)
  if not url then
    vim.notify(not_found_message, vim.log.levels.WARN)
    return
  end

  vim.ui.open(url)
end

vim.api.nvim_create_user_command("Pypi", open_pypi_project, { range = true })
vim.api.nvim_create_user_command("PypiRepo", function(opts)
  open_pypi_metadata_url({
    "source",
    "source code",
    "repository",
    "repo",
    "homepage",
    "home",
    "home_page",
  }, "Repository URL not found on PyPI", opts)
end, { range = true })
vim.api.nvim_create_user_command("PypiDocs", function(opts)
  open_pypi_metadata_url({
    "documentation",
    "docs",
    "doc",
    "homepage",
    "home",
    "home_page",
  }, "Documentation URL not found on PyPI", opts)
end, { range = true })
