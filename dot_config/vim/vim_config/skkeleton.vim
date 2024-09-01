UsePlugin 'skkeleton'

imap <C-j> <Plug>(skkeleton-enable)
cmap <C-j> <Plug>(skkeleton-enable)
function! s:skkeleton_init() abort
  call skkeleton#config({
    \ 'userDictionary': '~/.config/skkeleton/userJisyo',
    \ 'globalDictionaries': ['~/.config/skk/SKK-JISYO.L'],
    \ 'eggLikeNewline': v:true
    \ })

  call skkeleton#register_kanatable('rom', {
        \  'z~': ['〜'],
        \})
endfunction
augroup skkeleton-initialize-pre
  autocmd!
  autocmd User skkeleton-initialize-pre call s:skkeleton_init()
augroup END
