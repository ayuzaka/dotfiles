local config_root = vim.fn.getcwd() .. "/dot_config/nvim"
local plenary_root = vim.fn.stdpath("data") .. "/lazy/plenary.nvim"

vim.opt.runtimepath:prepend(config_root)
vim.opt.runtimepath:append(plenary_root)
