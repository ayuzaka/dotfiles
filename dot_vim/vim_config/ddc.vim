UsePlugin 'ddc.vim'

call ddc#custom#patch_global('ui', 'native')

let g:ddc_source_lsp_param_snippetEngine = 'vim-lsp'
call ddc#custom#patch_global('sources', ['lsp', 'skkeleton'])
call ddc#custom#patch_global('sourceOptions', #{
    \   _: #{
    \     matchers: ['matcher_head'],
    \     sorters: ['sorter_rank']
    \   },
    \   skkeleton: #{
    \     mark: 'skkeleton',
    \     matchers: ['skkeleton'],
    \     sorters: []
    \   },
    \   lsp: #{
    \     mark: 'lsp',
    \     forceCompletionPattern: '\.\w*|:\w*|->\w*',
    \   },
    \ })

call ddc#custom#patch_global('sourceParams', #{
      \   lsp: #{
      \     snippetEngine: denops#callback#register({
      \           body -> vsnip#anonymous(body)
      \     }),
      \     enableResolveItem: v:true,
      \     enableAdditionalTextEdit: v:true,
      \   }
      \ })

" <TAB>: completion.
inoremap <silent><expr> <TAB>
\ pumvisible() ? '<C-n>' :
\ (col('.') <= 1 <Bar><Bar> getline('.')[col('.') - 2] =~# '\s') ?
\ '<TAB>' : ddc#map#manual_complete()

" <S-TAB>: completion back.
inoremap <expr><S-TAB>  pumvisible() ? '<C-p>' : '<C-h>'

" Use ddc.
call ddc#enable()
