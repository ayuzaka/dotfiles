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
