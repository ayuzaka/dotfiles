-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- optionally enable 24-bit colour
vim.opt.termguicolors = true

-- empty setup using defaults
require("nvim-tree").setup()

-- OR setup with some options
require("nvim-tree").setup({
  sort = {
    sorter = "case_sensitive",
  },
  view = {
    width = 30,
  },
  renderer = {
    group_empty = true,
  },
  filters = {
    dotfiles = true,
  },
  update_focused_file = {
    enable = true,
    update_root = true,
  },
  git = {
    enable = false,
  },
})

vim.api.nvim_create_user_command('FilerOpen', function(opts)
  vim.cmd('NvimTreeOpen ' .. (opts.args or ''))
end, {
  desc = 'Open nvim-tree file explorer',
  nargs = '?',
  complete = 'dir'
})

vim.api.nvim_create_user_command('FilerClose', function(opts)
  vim.cmd('NvimTreeClose ' .. (opts.args or ''))
end, {
  desc = 'Close nvim-tree file explorer',
  nargs = '?',
  complete = 'dir'
})
