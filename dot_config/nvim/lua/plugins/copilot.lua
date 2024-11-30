vim.g.copilot_filetypes = {
  dotenv = false
}

vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "/Users/ayuzaka/Documents/MyFirstObsidian/",
  callback = function()
    vim.cmd("Echo 'Hello'")
  end
})
