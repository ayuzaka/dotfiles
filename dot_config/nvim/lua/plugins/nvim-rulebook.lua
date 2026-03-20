require("rulebook").setup({
  ruleDocs = {
    oxlint = function(diag)
      local href = vim.tbl_get(diag, "user_data", "lsp", "codeDescription", "href")
      if type(href) == "string" and href ~= "" then
        return href
      end

      local code = type(diag.code) == "string" and diag.code or ""
      if code:match("^[%w%-_]+/[%w%-_]+$") then
        return "https://oxc.rs/docs/guide/usage/linter/rules/" .. code .. ".html"
      end
    end,
  },
})

vim.keymap.set("n", "<leader>rl", function() require("rulebook").lookupRule() end, { desc = "Lookup linter rule" })
vim.keymap.set("n", "<leader>ri", function() require("rulebook").ignoreRule() end, { desc = "Ignore linter rule" })
