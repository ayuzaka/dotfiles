local ok, lines = pcall(vim.fn.readfile, vim.fn.expand("~/.config/theme"))
vim.opt.background = (ok and lines[1] and vim.trim(lines[1]) == "dark") and "dark" or "light"

vim.g.everforest_background = "soft"
vim.g.everforest_enable_italic = true
vim.g.everforest_float_style = "dim"
vim.g.everforest_ui_contrast = "high"
vim.g.everforest_diagnostic_virtual_text = "colored"
vim.g.everforest_inlay_hints_background = "dimmed"
vim.g.everforest_show_eob = false
vim.g.everforest_better_performance = true

vim.cmd.colorscheme("everforest")
