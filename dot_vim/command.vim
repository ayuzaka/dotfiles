command! CopyFile let @* = expand('%:t')
command! CopyPath let @* = expand('%:p')

function! RunOpenPR()
  let word = expand('<cword>')
  execute '!git rev-parse ' . word . ' | xargs gh openpr'
endfunction

command! -nargs=0 OpenPR :call RunOpenPR()

function! SearchRegex(text)
  call histdel('/')
  let @/= a:text
  call histadd('/', @/)
  execute '/' . @/
endfunction

command! SearchFullWidthEn :call SearchRegex('[Ａ-Ｚａ-ｚ]')
command! SearchFullWidthNum :call SearchRegex('[０-９]')
command! SearchFullWidth :call SearchRegex('[Ａ-Ｚａ-ｚ０-９]')
