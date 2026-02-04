local abbrev_group = vim.api.nvim_create_augroup("my_abbrev", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "typescript", "typescriptreact" },
  group = abbrev_group,
  callback = function()
    local abbrevs = {
      ex = "export",
      im = "import",
      con = "console",
      cosnt = "const",
    }

    for from, to in pairs(abbrevs) do
      vim.cmd(string.format("iabbrev <buffer> %s %s", from, to))
    end
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown" },
  group = abbrev_group,
  callback = function()
    local abbrevs = {
      restful = "RESTful",
    }

    for from, to in pairs(abbrevs) do
      vim.cmd(string.format("iabbrev <buffer> %s %s", from, to))
    end
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "sql" },
  group = abbrev_group,
  callback = function()
    local keywords = {
      "SELECT", "FROM", "WHERE", "AND", "OR", "NOT",
      "INSERT", "INTO", "VALUES", "UPDATE", "SET", "DELETE",
      "CREATE", "ALTER", "DROP", "TABLE", "INDEX", "VIEW",
      "JOIN", "INNER", "LEFT", "RIGHT", "OUTER", "CROSS", "ON",
      "GROUP", "BY", "ORDER", "HAVING", "LIMIT", "OFFSET",
      "AS", "IN", "IS", "NULL", "BETWEEN", "LIKE", "EXISTS",
      "DISTINCT", "UNION", "ALL", "ANY", "CASE", "WHEN", "THEN", "ELSE", "END",
      "PRIMARY", "KEY", "FOREIGN", "REFERENCES", "CONSTRAINT",
      "DEFAULT", "CHECK", "UNIQUE", "CASCADE",
      "BEGIN", "COMMIT", "ROLLBACK", "TRANSACTION",
      "GRANT", "REVOKE", "WITH", "ASC", "DESC",
      "COUNT", "SUM", "AVG", "MIN", "MAX",
      "IF", "REPLACE", "TRUNCATE", "DATABASE", "SCHEMA",
      "ADD", "COLUMN", "RENAME", "TO",
    }

    for _, keyword in ipairs(keywords) do
      local lower = keyword:lower()
      vim.cmd(string.format("iabbrev <buffer> %s %s", lower, keyword))
    end
  end,
})
