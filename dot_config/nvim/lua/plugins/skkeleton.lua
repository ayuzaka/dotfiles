vim.keymap.set('i', '<C-j>', '<Plug>(skkeleton-enable)')
vim.keymap.set('c', '<C-j>', '<Plug>(skkeleton-enable)')

local function skkeleton_init()
  vim.fn['skkeleton#config']({
    userDictionary = '~/.config/skkeleton/userJisyo',
    globalDictionaries = { '~/.config/skk/SKK-JISYO.L' },
    eggLikeNewline = true
  })

  vim.fn['skkeleton#register_kanatable']('rom', {
    ['z~'] = { '〜' },
    ['('] = { '（' },
    [')'] = { '）' },
    ['!'] = { '！' },
    ['?'] = { '？' },
    ['~'] = { '〜' },
  })
end

local skkeleton_group = vim.api.nvim_create_augroup('skkeleton-initialize-pre', { clear = true })

vim.api.nvim_create_autocmd('User', {
  pattern = 'skkeleton-initialize-pre',
  group = skkeleton_group,
  callback = skkeleton_init
})
