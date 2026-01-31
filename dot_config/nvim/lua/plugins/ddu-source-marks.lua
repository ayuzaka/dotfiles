vim.keymap.set("n", "<Leader>m", function()
  vim.fn["ddu#start"]({ name = "marks" })
end, { silent = true })
