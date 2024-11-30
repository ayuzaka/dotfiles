vim.api.nvim_create_user_command("Gs", function()
  vim.fn["ddu#start"]({ name = "git_status" })
end, {})
