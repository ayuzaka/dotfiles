local deno_lint = require("plugins.nvim_rulebook.deno_lint")
local golangci_lint = require("plugins.nvim_rulebook.golangci_lint")
local oxlint = require("plugins.nvim_rulebook.oxlint")
local rulebook = require("rulebook")

rulebook.setup({
  forwSearchLines = 10,
  ignoreComments = {
    ["golangci-lint"] = golangci_lint.ignore_comment,
    golangci_lint_ls = golangci_lint.ignore_comment,
    ["deno-lint"] = deno_lint.ignore_comment,
    oxlint = oxlint.ignore_comment,
    oxc = oxlint.ignore_comment,
  },
  ruleDocs = {
    ["golangci-lint"] = golangci_lint.rule_url,
    golangci_lint_ls = golangci_lint.rule_url,
    oxlint = oxlint.rule_url,
    oxc = oxlint.rule_url,
    ["deno-lint"] = deno_lint.rule_url,
  },
  suppressFormatter = require("rulebook.data.suppress-formatter-comment"),
  prettifyError = require("rulebook.data.prettify-error"),
})

local rulebook_config = require("rulebook.config").config

for _, linter_name in ipairs(golangci_lint.get_linter_names()) do
  if rulebook_config.ignoreComments[linter_name] == nil then
    rulebook_config.ignoreComments[linter_name] = golangci_lint.ignore_comment
  end
  if rulebook_config.ruleDocs[linter_name] == nil then
    rulebook_config.ruleDocs[linter_name] = golangci_lint.rule_url
  end
end

vim.keymap.set("n", "<leader>rl", function() rulebook.lookupRule() end, { desc = "Lookup linter rule" })
vim.keymap.set("n", "<leader>ri", function() rulebook.ignoreRule() end, { desc = "Ignore linter rule" })
