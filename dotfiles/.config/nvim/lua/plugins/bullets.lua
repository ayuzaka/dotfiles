vim.g.bullets_enabled_file_types = { "markdown", "text", "gitcommit" }
vim.g.bullets_set_mappings = 0

vim.g.bullets_custom_mappings = {
  { "imap", "<CR>", "<Plug>(bullets-newline)" },
  { "inoremap", "<C-cr>", "<CR>" },

  { "nmap", "o", "<Plug>(bullets-newline)" },

  { "vmap", "gN", "<Plug>(bullets-renumber)" },
  { "nmap", "gN", "<Plug>(bullets-renumber)" },

  { "nmap", "<leader>x", "<Plug>(bullets-toggle-checkbox)" },

  { "nmap", ">>", "<Plug>(bullets-demote)" },
  { "vmap", ">", "<Plug>(bullets-demote)" },

  { "nmap", "<<", "<Plug>(bullets-promote)" },
  { "vmap", "<", "<Plug>(bullets-promote)" },
}
