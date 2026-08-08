vim.api.nvim_create_user_command("Buffer", function()
  vim.fn["ddu#start"]({
    sources = {
      {
        name = "buffer",
      }
    }
  })
end, {})

vim.keymap.set("n", "<C-S-p>", function()
  vim.fn["ddu#start"]({ name = "buffer_list" })
end, { silent = true })
