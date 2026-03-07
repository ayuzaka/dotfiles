vim.api.nvim_create_user_command("GhPrDiff", function()
  vim.fn["ddu#start"]({ name = "gh_pr_diff", sources = { { name = "gh_pr_diff" } } })
end, {})
