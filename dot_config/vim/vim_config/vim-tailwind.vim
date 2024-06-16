UsePlugin 'vim-tailwind'

function! s:is_tailwind()
  return !empty(findfile('tailwind.config.js', '.;')) ||
       \ !empty(findfile('config/tailwind.config.js', '.;'))
endfunction

autocmd BufEnter *.tsx if s:is_tailwind() |
      \   setlocal omnifunc=tailwind#Complete |
      \ endif

command! TailwindClass call feedkeys("\<Plug>(tailwind-lookup)")
