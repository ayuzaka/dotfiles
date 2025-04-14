vim.g.copilot_filetypes = {
  dotenv = false
}

vim.api.nvim_create_augroup('disableGitHubCopilot', { clear = true })

vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
  group = 'disableGitHubCopilot',
  pattern = {
    vim.fn.expand('$HOME') .. '/workspace/ayuzaka/learn/*',
    vim.fn.expand('$HOME') .. '**/Documents/daily/*',
  },
  callback = function()
    vim.cmd('Copilot disable')
  end
})

