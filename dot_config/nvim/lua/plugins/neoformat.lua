vim.g.neoformat_try_node_exe = 1

vim.api.nvim_create_user_command("Prettier", "Neoformat prettier", {})
vim.api.nvim_create_user_command("BiomeFormat", "Neoformat biome", {})
vim.api.nvim_create_user_command("SQLFormatter", "Neoformat sqlformatter", {})
