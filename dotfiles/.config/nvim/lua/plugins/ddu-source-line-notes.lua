vim.keymap.set("n", "<leader>dc", function()
  vim.fn["ddu#start"]({ name = "line-notes" })
end, { silent = true, desc = "ddu line notes" })
