vim.api.nvim_create_user_command("GitStatus", function()
  vim.fn["ddu#start"]({ name = "git_status" })
end, {})
