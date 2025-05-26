vim.keymap.set('i', '<C-n>', '<Cmd>call pum#map#insert_relative(+1)<CR>', { noremap = true })
vim.keymap.set('i', '<C-p>', '<Cmd>call pum#map#insert_relative(-1)<CR>', { noremap = true })
vim.keymap.set('i', '<C-y>', '<Cmd>call pum#map#confirm()<CR>', { noremap = true })
vim.keymap.set('i', '<C-e>', '<Cmd>call pum#map#cancel()<CR>', { noremap = true })
vim.keymap.set('i', '<PageDown>', '<Cmd>call pum#map#insert_relative_page(+1)<CR>', { noremap = true })
vim.keymap.set('i', '<PageUp>', '<Cmd>call pum#map#insert_relative_page(-1)<CR>', { noremap = true })

