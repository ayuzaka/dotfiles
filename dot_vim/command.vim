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

function! ConvertByUconv(command)
  let l:word = expand('<cword>')
  let l:converted_word = system('uconv -x ' . a:command . ' <<< ' . shellescape(l:word))

  execute 'substitute/\V\<' . escape(l:word, '/'). '\>/' . l:converted_word . '/g'
endfunction

command! ConvertHalfwidth :call ConvertByUconv('fullwidth-halfwidth')
command! ConvertFullwidth :call ConvertByUconv('halfwidth-fullwidth')
command! ConvertKatakana :call ConvertByUconv('katakana')
