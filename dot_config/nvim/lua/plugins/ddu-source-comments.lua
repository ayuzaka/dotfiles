vim.keymap.set("n", "<leader>dc", function()
  vim.fn["ddu#start"]({ name = "comments" })
end, { silent = true, desc = "ddu comments" })
