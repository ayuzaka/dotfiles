UsePlugin 'vim-fugitive'

function! GitShowCurrentHash()
    let hash = expand('<cword>')
    execute ':Git show ' . hash
endfunction

command! Gs call GitShowCurrentHash()
command! Gb :Git blame
