UsePlugin 'vim-fugitive'

function! GitShowCurrentHash() abort
    let hash = expand('<cword>')
    execute ':Git show ' . hash
endfunction

command! Gb :Git blame
