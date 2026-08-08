require('mini.diff').setup {
  view = {
    style = 'sign',
    signs = { add = '┃', change = '┃', delete = '_' },
  },
  mappings = {
    goto_next = ']c',
    goto_prev = '[c',
  },
}
