" ~/.vim が無いとき runtimepath の先頭は ~/.config/vim になる。
" plug#begin は autoload/plug.vim をそこから読む。
let s:plug_vim = expand('~/.config/vim/autoload/plug.vim')
if !filereadable(s:plug_vim)
  call system([
        \ 'curl', '--fail', '--silent', '--show-error', '--location',
        \ '--create-dirs', '--output', s:plug_vim,
        \ 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim',
        \ ])
  if v:shell_error || !filereadable(s:plug_vim)
    echoerr 'vim-plug の取得に失敗しました'
    finish
  endif
endif

call plug#begin('~/.local/share/vim/plugged')

Plug 'sainnhe/everforest'
Plug 'andymass/vim-matchup'
Plug 'rhysd/vim-fixjson'
Plug 'preservim/vim-markdown'
Plug 'bullets-vim/bullets.vim'
Plug 'machakann/vim-sandwich'

call plug#end()

let s:missing_plugs = filter(values(g:plugs), '!isdirectory(v:val.dir)')
if !empty(s:missing_plugs)
  PlugInstall
  if empty(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
    let s:plug_buf = bufnr('[Plugins]')
    if s:plug_buf > 0
      execute 'silent! bwipeout!' s:plug_buf
    endif
    messages clear
  endif
endif

