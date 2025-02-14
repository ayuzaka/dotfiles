UsePlugin 'ddc.vim'

call ddc#custom#patch_global('ui', 'native')

call ddc#custom#patch_global('sources', ['skkeleton'])
call ddc#custom#patch_global('sourceOptions', {
    \   '_': {
    \     'matchers': ['matcher_head'],
    \     'sorters': ['sorter_rank']
    \   },
    \   'skkeleton': {
    \     'mark': 'skkeleton',
    \     'matchers': [],
    \     'sorters': [],
    \     'converters': [],
    \     'isVolatile': v:true,
    \     'minAutoCompleteLength': 1,
    \   },
    \ })
call skkeleton#config({'completionRankFile': '~/.skkeleton/rank.json'})

" <TAB>: completion.
inoremap <silent><expr> <TAB>
\ pumvisible() ? '<C-n>' :
\ (col('.') <= 1 <Bar><Bar> getline('.')[col('.') - 2] =~# '\s') ?
\ '<TAB>' : ddc#map#manual_complete()

" <S-TAB>: completion back.
inoremap <expr><S-TAB>  pumvisible() ? '<C-p>' : '<C-h>'

" Use ddc.
call ddc#enable()
