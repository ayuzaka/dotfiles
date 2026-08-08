UsePlugin 'vim-airline'
UsePlugin 'vim-airline-themes'

let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#fnamemod = ':t'
let g:airline#extensions#tabline#formatter = 'unique_tail_improved'
let g:airline_section_a = airline#section#create([])
let g:airline_section_b = airline#section#create([])
let g:airline_section_x = airline#section#create(['tagbar'])
let g:airline_section_y = airline#section#create([])
let g:airline_section_z = airline#section#create([])
