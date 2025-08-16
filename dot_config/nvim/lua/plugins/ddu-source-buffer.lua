vim.api.nvim_create_user_command("Buffer", function()
  vim.fn["ddu#start"]({
    sources = {
      {
        name = "buffer",
      }
    }
  })
end, {})

