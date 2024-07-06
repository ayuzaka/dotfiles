command! CopyFile let @* = expand('%:t')
command! CopyPath let @* = expand('%:p')

" buffer
nnoremap <silent> b, :bprev<CR>
nnoremap <silent> b. :bnext<CR>
nnoremap bd :bd<CR>

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
command! SearchFullWidthSpace :call SearchRegex('[　]\+')
command! SearchFullWidth :call SearchRegex('[Ａ-Ｚａ-ｚ　０-９]\+')

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

function! AddSpell(arg = '') abort
  let l:word = a:arg == '' ? expand('<cword>') : a:arg
  let l:file = "$XDG_DATA_HOME/cspell/dict-custom.txt"

  execute 'redir >> ' . l:file
  silent echo tolower(l:word)
  redir END

  echo 'Added "' . l:word . '"'
endfunction

command! -nargs=* SpellAdd call AddSpell(<f-args>)

command! Profile call s:command_profile()
function! s:command_profile() abort
  profile start ~/profile.txt
  profile func *
  profile file *
endfunction

" https://github.com/vim-scripts/BufOnly.vim/
command! -nargs=? -complete=buffer -bang BufOnly
    \ :call BufOnly('<args>', '<bang>')

function! BufOnly(buffer, bang)
  if a:buffer == ''
    " No buffer provided, use the current buffer.
    let buffer = bufnr('%')
  elseif (a:buffer + 0) > 0
    " A buffer number was provided.
    let buffer = bufnr(a:buffer + 0)
  else
    " A buffer name was provided.
    let buffer = bufnr(a:buffer)
  endif
 
  if buffer == -1
    echohl ErrorMsg
    echomsg "No matching buffer for" a:buffer
    echohl None
    return
  endif

  let last_buffer = bufnr('$')

  let delete_count = 0
  let n = 1
  while n <= last_buffer
    if n != buffer && buflisted(n)
      if a:bang == '' && getbufvar(n, '&modified')
        echohl ErrorMsg
        echomsg 'No write since last change for buffer'
          \ n '(add ! to override)'
        echohl None
      else
        silent exe 'bdel' . a:bang . ' ' . n
        if ! buflisted(n)
          let delete_count = delete_count+1
        endif
      endif
    endif
    let n = n+1
  endwhile

  if delete_count == 1
    echomsg delete_count "buffer deleted"
  elseif delete_count > 1
    echomsg delete_count "buffers deleted"
  endif
endfunction

function! GitBrowseCurrent() abort
  let dir_path = fnamemodify(expand('%'), ':~:.')
  execute '!git browse --path=' . dir_path
endfunction

command! GitBrowse :call GitBrowseCurrent()
