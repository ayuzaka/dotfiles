local function oxlint_rule_url(diag)
  local href = vim.tbl_get(diag, "user_data", "lsp", "codeDescription", "href")
  if type(href) == "string" and href ~= "" then
    return href
  end

  local base = "https://oxc.rs/docs/guide/usage/linter/rules/"
  local code = type(diag.code) == "string" and diag.code or ""

  -- category/rule 形式
  if code:match("^[%w%-_]+/[%w%-_]+$") then
    return base .. code .. ".html"
  end

  -- eslint-plugin-NAME(RULE) 形式
  local plugin, rule = code:match("^eslint%-plugin%-([%w%-_]+)%(([%w%-_]+)%)$")
  if plugin and rule then
    return base .. plugin .. "/" .. rule .. ".html"
  end

  -- message から category/rule を抽出
  local msg = type(diag.message) == "string" and diag.message or ""
  local rule_path = msg:match("([%w%-_]+/[%w%-_]+)")
  if rule_path then
    return base .. rule_path .. ".html"
  end
end

require("rulebook").setup({
  forwSearchLines = 10,
  ignoreComments = require("rulebook.data.add-ignore-rule-comment"),
  ruleDocs = vim.tbl_deep_extend("force", require("rulebook.data.rule-docs"), {
    oxlint = oxlint_rule_url,
    oxc = oxlint_rule_url,
  }),
  suppressFormatter = require("rulebook.data.suppress-formatter-comment"),
  prettifyError = require("rulebook.data.prettify-error"),
})

vim.keymap.set("n", "<leader>rl", function() require("rulebook").lookupRule() end, { desc = "Lookup linter rule" })
vim.keymap.set("n", "<leader>ri", function() require("rulebook").ignoreRule() end, { desc = "Ignore linter rule" })
