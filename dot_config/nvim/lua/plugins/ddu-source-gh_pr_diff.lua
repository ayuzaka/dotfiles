vim.api.nvim_create_user_command("GhPrDiff", function()
  vim.fn["ddu#start"]({ sources = { { name = "gh_pr_diff" } } })
end, {})
