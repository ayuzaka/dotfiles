vim.keymap.set("n", "<C-p>", function()
  vim.fn["ddu#start"]({ name = "fd" })
end, { silent = true })

vim.api.nvim_create_user_command("PRDiffFile", function()
  vim.fn["ddu#start"]({ name = "gh_pr_diff_file" })
end, {})
