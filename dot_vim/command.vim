command! CopyFile let @* = expand('%:t')
command! CopyPath let @* = expand('%:p')

function! RunOpenPR() abort
  let word = expand('<cword>')
  execute '!git rev-parse ' . word . ' | xargs gh openpr'
endfunction

command! -nargs=0 OpenPR :call RunOpenPR()

function! SearchRegex(text) abort
  call histdel('/')
  let @/= a:text
  call histadd('/', @/)
  execute '/' . @/
endfunction

command! SearchFullWidthEn :call SearchRegex('[Ａ-Ｚａ-ｚ]\+')
command! SearchFullWidthNum :call SearchRegex('[０-９]\+')
command! SearchFullWidth :call SearchRegex('[Ａ-Ｚａ-ｚ０-９]\+')

function! FullToHalf() abort
  let l:word = expand('<cword>')
  let l:halfwidth_word = ''

  for l:char in split(l:word, '\zs')
    if char2nr(l:char) >= 65281 && char2nr(l:char) <= 65370
      let l:halfwidth_word .= nr2char(char2nr(l:char) - 65248)
    else
      let l:halfwidth_word .= l:char
    endif
  endfor

  execute a:firstline . ',' . a:lastline . 'substitute/\V\<' . escape(l:word, '/'). '\>/' . l:halfwidth_word . '/g'
endfunction

function! HalfToFull() abort
    let l:word = expand('<cword>')
    let l:fullwidth_word = ''

    for l:char in split(l:word, '\zs')
        if char2nr(l:char) >= 33 && char2nr(l:char) <= 126
            let l:fullwidth_word .= nr2char(char2nr(l:char) + 65248)
        else
            let l:fullwidth_word .= l:char
        endif
    endfor

    execute a:firstline . ',' . a:lastline . 'substitute/\V\<' . escape(l:word, '/') . '\>/' . l:fullwidth_word . '/g'
endfunction

command! FullToHalf :call FullToHalf()
command! HalfToFull :call HalfToFull()

function! AddSpell() abort
  let l:word = expand('<cword>')
  let l:file = "$XDG_DATA_HOME/cspell/dict-custom.txt"

  execute 'redir >> ' . l:file
  silent echo tolower(l:word)
  redir END
endfunction

command! SpellAdd :call AddSpell()
