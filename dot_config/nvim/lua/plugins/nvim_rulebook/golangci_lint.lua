local M = {}

local linter_names

local function get_rule_name(diag)
  local code = type(diag.code) == "string" and diag.code or ""
  code = code:match("^%(([^)]+)%)$") or code
  if code == "" then
    local msg = type(diag.message) == "string" and diag.message or ""
    code = msg:match("^([%w_]+):")
  end
  if code ~= "" then return code end

  local source = type(diag.source) == "string" and diag.source or ""
  if source ~= "" and source ~= "golangci-lint" and source ~= "golangci_lint_ls" then
    return source
  end
end

function M.rule_url(diag)
  local href = vim.tbl_get(diag, "user_data", "lsp", "codeDescription", "href")
  if type(href) == "string" and href ~= "" then
    return href
  end

  local rule_name = get_rule_name(diag)
  if rule_name ~= nil then
    return "https://golangci-lint.run/docs/linters/configuration/#" .. rule_name
  end

  return "https://golangci-lint.run/docs/linters/"
end

M.ignore_comment = {
  comment = function(diag)
    local rule_name = get_rule_name(diag)
    if rule_name == nil then
      return "//nolint"
    end
    return "//nolint:" .. rule_name
  end,
  location = "prevLine",
  doesNotUseCodes = true,
  multiRuleIgnore = false,
  docs = "https://golangci-lint.run/docs/linters/false-positives/#nolint-directive",
}

function M.get_linter_names()
  if linter_names ~= nil then
    return linter_names
  end

  linter_names = {}

  if vim.fn.executable("golangci-lint") ~= 1 then
    return linter_names
  end

  local result = vim.system({ "golangci-lint", "help", "linters", "--json" }, { text = true }):wait()
  if result.code ~= 0 then
    return linter_names
  end

  local ok, linters = pcall(vim.json.decode, result.stdout)
  if not ok or type(linters) ~= "table" then
    return linter_names
  end

  for _, linter in ipairs(linters) do
    if type(linter) == "table" and type(linter.name) == "string" and linter.name ~= "" then
      table.insert(linter_names, linter.name)
    end
  end

  return linter_names
end

return M
