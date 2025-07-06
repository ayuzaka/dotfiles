vim.api.nvim_create_user_command("FileHistory", function()
  vim.fn["ddu#start"]({
    sources = {
      {
        name = "git_log",
        options = {
          path = vim.fn.expand("%:p:h"),
        },
        params = {
          startingCommits = { "--", vim.fn.expand("%:t") }
        }
      }
    }
  })
end, {})
