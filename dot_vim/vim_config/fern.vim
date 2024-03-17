UsePlugin 'fern.vim'
UsePlugin 'fern-renderer-nerdfont.vim'
UsePlugin 'nerdfont.vim'

let g:fern#renderer = "nerdfont"

command! Fd :Fern . -drawer
command! FdCurrent :Fern . -reveal=% -drawer
