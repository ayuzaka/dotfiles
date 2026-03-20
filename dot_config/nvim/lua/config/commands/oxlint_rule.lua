local lsp = require("config.lsp")
local utils = require("config.utils")

local OXLINT_SOURCE = "oxlint"
local OXLINT_RULE_URL_PREFIX = "https://oxc.rs/docs/guide/usage/linter/rules/"

local function normalize_rule_path(rule_path)
  local normalized_rule_path = rule_path
    :gsub("^.*/rules/", "")
    :gsub("^/?", "")
    :gsub("%.html?$", "")

  if normalized_rule_path:match("^[%w-_]+/[%w-_]+$") == nil then
    return nil
  end

  return normalized_rule_path
end

local function extract_rule_path_from_text(text)
  if type(text) ~= "string" then
    return nil
  end

  local rule_path = text:match("([%w-_]+/[%w-_]+)")

  if rule_path == nil then
    return nil
  end

  return normalize_rule_path(rule_path)
end

local function resolve_oxlint_rule_url(diagnostic)
  local lsp_diagnostic = vim.tbl_get(diagnostic, "user_data", "lsp")
  local href = vim.tbl_get(lsp_diagnostic, "codeDescription", "href")

  if type(href) == "string" and href ~= "" then
    return href
  end

  local code_rule_path = extract_rule_path_from_text(diagnostic.code)
  if code_rule_path ~= nil then
    return OXLINT_RULE_URL_PREFIX .. code_rule_path .. ".html"
  end

  local message_rule_path = extract_rule_path_from_text(diagnostic.message)
  if message_rule_path ~= nil then
    return OXLINT_RULE_URL_PREFIX .. message_rule_path .. ".html"
  end

  return nil
end

local function is_oxlint_namespace(diagnostic)
  local namespace_name = utils.get_diagnostic_namespace_name(diagnostic)

  return type(namespace_name) == "string" and namespace_name:match("^vim%.lsp%.oxlint%.")
end

local function is_oxlint_diagnostic(diagnostic)
  if diagnostic.source == OXLINT_SOURCE then
    return true
  end

  if is_oxlint_namespace(diagnostic) then
    return true
  end

  return resolve_oxlint_rule_url(diagnostic) ~= nil
end

local function collect_oxlint_diagnostics_at_cursor(bufnr, line, col)
  local diagnostics = vim.diagnostic.get(bufnr)
  local oxlint_diagnostics = vim.tbl_filter(is_oxlint_diagnostic, diagnostics)
  local cursor_diagnostics = vim.tbl_filter(function(diagnostic)
    return lsp.is_cursor_in_diagnostic(diagnostic, line, col)
  end, oxlint_diagnostics)

  if #cursor_diagnostics > 0 then
    return cursor_diagnostics
  end

  return vim.tbl_filter(function(diagnostic)
    return diagnostic.lnum <= line and diagnostic.end_lnum >= line
  end, oxlint_diagnostics)
end

local function open_oxlint_rule()
  local bufnr = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local line = cursor[1] - 1
  local col = cursor[2]
  local diagnostics = collect_oxlint_diagnostics_at_cursor(bufnr, line, col)

  if #diagnostics == 0 then
    vim.notify("カーソル位置に oxlint の diagnostic がありません", vim.log.levels.INFO)
    return
  end

  local open_rule = function(diagnostic)
    local url = resolve_oxlint_rule_url(diagnostic)

    if url == nil then
      vim.notify("oxlint ルール URL を解決できませんでした", vim.log.levels.WARN)
      return
    end

    vim.ui.open(url)
  end

  if #diagnostics == 1 then
    open_rule(diagnostics[1])
    return
  end

  vim.ui.select(diagnostics, {
    prompt = "開く oxlint ルールを選択",
    format_item = lsp.format_diagnostic_choice,
  }, function(selected_diagnostic)
    if selected_diagnostic == nil then
      return
    end

    open_rule(selected_diagnostic)
  end)
end

vim.api.nvim_create_user_command("OxlintRule", open_oxlint_rule, {})
