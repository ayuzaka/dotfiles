local utils = require("config.utils")

local ESLINT_SOURCE = "eslint"
local ESLINT_CORE_URL_PREFIX = "https://eslint.org/docs/latest/rules/"

local PLUGIN_URL_PATTERNS = {
  ["@typescript-eslint"] = "https://typescript-eslint.io/rules/%s",
  ["react"] = "https://github.com/jsx-eslint/eslint-plugin-react/blob/master/docs/rules/%s.md",
  ["react-hooks"] = "https://react.dev/reference/eslint-plugin-react-hooks/lints/%s",
  ["import"] = "https://github.com/import-js/eslint-plugin-import/blob/main/docs/rules/%s.md",
  ["jsx-a11y"] = "https://github.com/jsx-eslint/eslint-plugin-jsx-a11y/blob/main/docs/rules/%s.md",
  ["unicorn"] = "https://github.com/sindresorhus/eslint-plugin-unicorn/blob/main/docs/rules/%s.md",
  ["n"] = "https://github.com/eslint-community/eslint-plugin-n/blob/master/docs/rules/%s.md",
  ["vue"] = "https://eslint.vuejs.org/rules/%s.html",
  ["tailwindcss"] = "https://github.com/francoismassart/eslint-plugin-tailwindcss/blob/master/docs/rules/%s.md",
}

local function is_cursor_in_diagnostic(diagnostic, line, col)
  if diagnostic.lnum > line or diagnostic.end_lnum < line then
    return false
  end

  if diagnostic.lnum == line and diagnostic.col > col then
    return false
  end

  if diagnostic.end_lnum == line and diagnostic.end_col <= col then
    return false
  end

  return true
end

-- Returns plugin, rule_name from an ESLint rule code.
-- Examples:
--   "no-unused-vars"                    -> nil, "no-unused-vars"
--   "react/jsx-key"                     -> "react", "jsx-key"
--   "@typescript-eslint/no-unused-vars" -> "@typescript-eslint", "no-unused-vars"
--   "@next/next/no-html-link-for-pages" -> "@next/next", "no-html-link-for-pages"
local function parse_rule_code(code)
  if type(code) ~= "string" or code == "" then
    return nil, nil
  end

  if code:sub(1, 1) == "@" then
    local scope, rest = code:match("^(@[^/]+)/(.+)$")
    if scope == nil then
      return nil, nil
    end

    local package, rule = rest:match("^([^/]+)/(.+)$")
    if package ~= nil then
      return scope .. "/" .. package, rule
    end

    return scope, rest
  end

  local plugin, rule = code:match("^([^/]+)/(.+)$")
  if plugin ~= nil then
    return plugin, rule
  end

  return nil, code
end

local function resolve_eslint_rule_url(diagnostic)
  local lsp_diagnostic = vim.tbl_get(diagnostic, "user_data", "lsp")
  local href = vim.tbl_get(lsp_diagnostic, "codeDescription", "href")

  if type(href) == "string" and href ~= "" then
    return href
  end

  local plugin, rule = parse_rule_code(diagnostic.code)

  if plugin == nil and rule ~= nil then
    return ESLINT_CORE_URL_PREFIX .. rule
  end

  if plugin ~= nil and rule ~= nil then
    local pattern = PLUGIN_URL_PATTERNS[plugin]
    if pattern ~= nil then
      return string.format(pattern, rule)
    end
  end

  return nil
end

local function is_eslint_namespace(diagnostic)
  local namespace_name = utils.get_diagnostic_namespace_name(diagnostic)

  return type(namespace_name) == "string" and namespace_name:match("^vim%.lsp%.eslint%.")
end

local function is_eslint_diagnostic(diagnostic)
  if diagnostic.source == ESLINT_SOURCE then
    return true
  end

  if is_eslint_namespace(diagnostic) then
    return true
  end

  return false
end

local function collect_eslint_diagnostics_at_cursor(bufnr, line, col)
  local diagnostics = vim.diagnostic.get(bufnr)
  local eslint_diagnostics = vim.tbl_filter(is_eslint_diagnostic, diagnostics)
  local cursor_diagnostics = vim.tbl_filter(function(diagnostic)
    return is_cursor_in_diagnostic(diagnostic, line, col)
  end, eslint_diagnostics)

  if #cursor_diagnostics > 0 then
    return cursor_diagnostics
  end

  return vim.tbl_filter(function(diagnostic)
    return diagnostic.lnum <= line and diagnostic.end_lnum >= line
  end, eslint_diagnostics)
end

local function format_diagnostic_choice(diagnostic)
  local code = type(diagnostic.code) == "string" and diagnostic.code or "unknown-rule"
  local message = diagnostic.message:gsub("%s+", " ")

  return string.format("%s: %s", code, message)
end

local function open_eslint_rule()
  local bufnr = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local line = cursor[1] - 1
  local col = cursor[2]
  local diagnostics = collect_eslint_diagnostics_at_cursor(bufnr, line, col)

  if #diagnostics == 0 then
    vim.notify("カーソル位置に ESLint の diagnostic がありません", vim.log.levels.INFO)
    return
  end

  local open_rule = function(diagnostic)
    local url = resolve_eslint_rule_url(diagnostic)

    if url == nil then
      vim.notify("ESLint ルール URL を解決できませんでした", vim.log.levels.WARN)
      return
    end

    vim.ui.open(url)
  end

  if #diagnostics == 1 then
    open_rule(diagnostics[1])
    return
  end

  vim.ui.select(diagnostics, {
    prompt = "開く ESLint ルールを選択",
    format_item = format_diagnostic_choice,
  }, function(selected_diagnostic)
    if selected_diagnostic == nil then
      return
    end

    open_rule(selected_diagnostic)
  end)
end

vim.api.nvim_create_user_command("EslintRule", open_eslint_rule, {})
