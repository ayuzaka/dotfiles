local M = {}

function M.rule_url(diag)
  local href = vim.tbl_get(diag, "user_data", "lsp", "codeDescription", "href")
  if type(href) == "string" and href ~= "" then
    return href
  end

  local base = "https://oxc.rs/docs/guide/usage/linter/rules/"
  local code = type(diag.code) == "string" and diag.code or ""

  if code:match("^[%w%-_]+/[%w%-_]+$") then
    return base .. code .. ".html"
  end

  local plugin, rule = code:match("^eslint%-plugin%-([%w%-_]+)%(([%w%-_]+)%)$")
  if plugin and rule then
    return base .. plugin .. "/" .. rule .. ".html"
  end

  local msg = type(diag.message) == "string" and diag.message or ""
  local rule_path = msg:match("([%w%-_]+/[%w%-_]+)")
  if rule_path then
    return base .. rule_path .. ".html"
  end
end

M.ignore_comment = {
  comment = "// oxlint-disable-next-line %s",
  location = "prevLine",
  multiRuleIgnore = true,
  multiRuleSeparator = ", ",
  docs = "https://oxc.rs/docs/guide/usage/linter/ignore-comments",
}

return M
