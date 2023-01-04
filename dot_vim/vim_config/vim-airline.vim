UsePlugin 'vim-airline'
UsePlugin 'vim-airline-themes'

let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#fnamemod = ':t'
let g:airline_section_a = airline#section#create(['mode', 'crypt'])
let g:airline_section_z = airline#section#create([])

nnoremap <silent> b, :bprev<CR>
nnoremap <silent> b. :bnext<CR>
nnoremap bd :bd<CR>
