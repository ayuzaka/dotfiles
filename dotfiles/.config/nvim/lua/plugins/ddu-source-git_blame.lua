vim.api.nvim_create_user_command("GitBlame", function()
  local filename = vim.fn.expand("%:p")
  if filename == "" then
    vim.notify("Current buffer has no file path", vim.log.levels.WARN)
    return
  end

  vim.fn["ddu#start"]({
    name = "git_blame",
    ui = "ff",
    sources = {
      {
        name = "git_blame",
        params = {
          filename = filename,
        },
        options = {
          columns = {
            { name = "git_blame", params = { kind = "commit"  } },
            { name = "git_blame", params = { kind = "author", authorWidth = 8 } },
            { name = "git_blame", params = { kind = "date"    } },
            { name = "git_blame", params = { kind = "summary" } },
          },
        },
      },
    },
  })
end, {})
