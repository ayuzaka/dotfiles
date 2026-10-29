vim.keymap.set('i', '<C-j>', '<Plug>(skkeleton-enable)')
vim.keymap.set('c', '<C-j>', '<Plug>(skkeleton-enable)')

local function skkeleton_init()
  local config = {
    userDictionary = '~/.config/skkeleton/userJisyo',
    globalDictionaries = { '~/.config/skk/SKK-JISYO.L' },
    eggLikeNewline = true,
  }

  -- skkeleton#register_completion_backend は #253 以降。lazy-lock のコミットへ
  -- restore する前の本体には無い。無いときは旧来の pum 自動判定に任せる。
  -- 登録に失敗して config / kanatable まで届かないと初期化全体が欠ける。
  if vim.fn.exists('*skkeleton#register_completion_backend') == 1 then
    -- pum.vim does not register a skkeleton backend; see pum-faq-10.
    vim.fn['skkeleton#register_completion_backend']('pum.vim', {
      complete_info = function()
        return vim.fn['pum#complete_info']({ 'pum_visible', 'selected' })
      end,
      confirm_key = '<Cmd>call pum#map#confirm()',
    })
    config.completionBackend = 'pum.vim'
  end

  vim.fn['skkeleton#config'](config)

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
