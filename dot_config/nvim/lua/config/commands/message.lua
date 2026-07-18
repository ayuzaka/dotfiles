vim.api.nvim_create_user_command("Messages", function()
  vim.cmd("new")
  vim.keymap.set("n", "q", "<Cmd>close<CR>", { buffer = true, silent = true })

  local messages = vim.fn.execute("messages")
  local lines = vim.split(messages, "\n", { plain = true })

  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
end, {})
