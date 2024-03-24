command! CopyFile let @* = expand('%:t')
command! CopyPath let @* = expand('%:p')

function! RunOpenPR()
  let word = expand('<cword>')
  execute '!git rev-parse ' . word . ' | xargs gh openpr'
endfunction

command! -nargs=0 OpenPR :call RunOpenPR()
