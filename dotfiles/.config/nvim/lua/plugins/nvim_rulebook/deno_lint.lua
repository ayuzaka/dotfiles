local M = {}

function M.rule_url(diag)
  local href = vim.tbl_get(diag, "user_data", "lsp", "codeDescription", "href")
  if type(href) == "string" and href ~= "" then
    return href
  end

  local code = type(diag.code) == "string" and diag.code or ""
  if code ~= "" then
    return "https://docs.deno.com/lint/rules/" .. code
  end
end

M.ignore_comment = {
  comment = "// deno-lint-ignore %s",
  location = "prevLine",
  multiRuleIgnore = true,
  multiRuleSeparator = " ",
  docs = "https://docs.deno.com/runtime/fundamentals/linting/#ignore-directives",
}

return M
