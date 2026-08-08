local textcase = require('textcase')

textcase.setup {
  default_keymappings_enabled = false,
  prefix = "ga",
  substitude_command_name = nil,
  enabled_methods = {
    "to_upper_case",
    "to_lower_case",
    "to_snake_case",
    "to_dash_case",
    "to_title_dash_case",
    "to_constant_case",
    "to_dot_case",
    "to_comma_case",
    "to_phrase_case",
    "to_camel_case",
    "to_pascal_case",
    "to_title_case",
    "to_path_case",
    "to_upper_phrase_case",
    "to_lower_phrase_case",
  },
}

vim.keymap.set('n', 'gau', function()
  textcase.current_word('to_upper_case')
end, { silent = true })

vim.keymap.set('n', 'gal', function()
  textcase.current_word('to_lower_case')
end, { silent = true })

vim.keymap.set('n', 'gas', function()
  textcase.current_word('to_snake_case')
end, { silent = true })

vim.keymap.set('n', 'gad', function()
  textcase.current_word('to_dash_case')
end, { silent = true })

vim.keymap.set('n', 'gan', function()
  textcase.current_word('to_constant_case')
end, { silent = true })

vim.keymap.set('n', 'ga.', function()
  textcase.current_word('to_dot_case')
end, { silent = true })

vim.keymap.set('n', 'ga,', function()
  textcase.current_word('to_comma_case')
end, { silent = true })

vim.keymap.set('n', 'gaa', function()
  textcase.current_word('to_phrase_case')
end, { silent = true })

vim.keymap.set('n', 'gac', function()
  textcase.current_word('to_camel_case')
end, { silent = true })

vim.keymap.set('n', 'gap', function()
  textcase.current_word('to_pascal_case')
end, { silent = true })

vim.keymap.set('n', 'gat', function()
  textcase.current_word('to_title_case')
end, { silent = true })

vim.keymap.set('n', 'gaf', function()
  textcase.current_word('to_path_case')
end, { silent = true })

vim.keymap.set('n', 'gaU', function()
  textcase.lsp_rename('to_upper_case')
end, { silent = true })

vim.keymap.set('n', 'gaL', function()
  textcase.lsp_rename('to_lower_case')
end, { silent = true })

vim.keymap.set('n', 'gaS', function()
  textcase.lsp_rename('to_snake_case')
end, { silent = true })

vim.keymap.set('n', 'gaD', function()
  textcase.lsp_rename('to_dash_case')
end, { silent = true })

vim.keymap.set('n', 'gaN', function()
  textcase.lsp_rename('to_constant_case')
end, { silent = true })

vim.keymap.set('n', 'ga.', function()
  textcase.lsp_rename('to_dot_case')
end, { silent = true })

vim.keymap.set('n', 'ga,', function()
  textcase.lsp_rename('to_comma_case')
end, { silent = true })

vim.keymap.set('n', 'gaA', function()
  textcase.lsp_rename('to_phrase_case')
end, { silent = true })

vim.keymap.set('n', 'gaC', function()
  textcase.lsp_rename('to_camel_case')
end, { silent = true })

vim.keymap.set('n', 'gaP', function()
  textcase.lsp_rename('to_pascal_case')
end, { silent = true })

vim.keymap.set('n', 'gaT', function()
  textcase.lsp_rename('to_title_case')
end, { silent = true })

vim.keymap.set('n', 'gaF', function()
  textcase.lsp_rename('to_path_case')
end, { silent = true })
