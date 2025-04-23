local abbrev_group = vim.api.nvim_create_augroup("my_abbrev", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  pattern = "sql",
  group = abbrev_group,
  callback = function()
    local abbrevs = {
      select = "SELECT",
      from = "FROM",
      where = "WHERE",
      order = "ORDER",
      by = "BY",
      desc = "DESC",
      asc = "ASC",
      group = "GROUP",
      having = "HAVING",
      inner = "INNER",
      join = "JOIN",
      left = "LEFT",
      right = "RIGHT",
      outer = "OUTER",
      on = "ON",
      as = "AS",
      distinct = "DISTINCT",
      count = "COUNT",
      sum = "SUM",
      avg = "AVG",
      max = "MAX",
      min = "MIN",
      like = "LIKE",
      between = "BETWEEN",
      null = "NULL",
      is = "IS",
      exists = "EXISTS",
      all = "ALL",
      any = "ANY",
      some = "SOME",
      union = "UNION",
      insert = "INSERT",
      into = "INTO",
      values = "VALUES",
      update = "UPDATE",
      set = "SET",
      delete = "DELETE",
      truncate = "TRUNCATE",
      create = "CREATE",
      table = "TABLE",
      alter = "ALTER",
      drop = "DROP",
      add = "ADD",
      column = "COLUMN",
      constraint = "CONSTRAINT",
      primary = "PRIMARY",
      key = "KEY",
      foreign = "FOREIGN",
      references = "REFERENCES",
      unique = "UNIQUE",
      check = "CHECK",
      default = "DEFAULT",
    }

    for from, to in pairs(abbrevs) do
      vim.cmd(string.format("iabbrev <buffer> %s %s", from, to))
    end
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "typescript", "typescriptreact" },
  group = abbrev_group,
  callback = function()
    local abbrevs = {
      fn = "function",
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
