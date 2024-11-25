vim.fn["ddu#custom#patch_local"]("git_status", {
  sources = {
    {
      name = "git_status"
    }
  },
  kindOptions = {
    git_status = {
      defaultAction = "open",
      actions = {}
    }
  }
})

vim.api.nvim_create_user_command("Gs", function()
  vim.fn["ddu#start"]({ name = "git_status" })
end, {})
