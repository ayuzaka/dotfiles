UsePlugin 'ddu-source-lsp'

let g:ddu_source_lsp_clientName = 'vim-lsp'

call ddu#custom#patch_global(#{
    \   kindOptions: #{
    \     lsp: #{
    \       defaultAction: 'open',
    \     },
    \     lsp_codeAction: #{
    \       defaultAction: 'apply',
    \     },
    \   },
    \ })

call ddu#custom#patch_local('lsp_definition', #{
      \  sync: v:true,
      \  sources: [#{
      \    name: 'lsp_definition',
      \    params: #{ method: 'textDocument/definition' },
      \  }],
      \})

call ddu#custom#patch_local('lsp_references', #{
      \  sync: v:true,
      \  sources: [#{
      \    name: 'lsp_references',
      \    params: #{
      \      method: 'textDocument/references',
      \      includeDeclaration: v:false,
      \    },
      \  }],
      \})

call ddu#custom#patch_local('codeAction', #{
      \  sources: [#{name: 'lsp_codeAction', params: #{ method: 'textDocument/codeAction' }}],
      \})

call ddu#custom#patch_local('lsp_diagnostic', #{
      \  sources: [#{
      \    name: 'lsp_diagnostic',
      \    params: #{
      \      clientName: 'vim-lsp',
      \    },
      \  }]
      \})

command! DduCodeAction :call ddu#start({"name": "codeAction"})
command! DduDef :call ddu#start({"name": "lsp_definition"})
command! DduRef :call ddu#start({"name": "lsp_references"})
command! DduDiagnostic :call ddu#start({"name": "lsp_diagnostic"})

nnoremap <C-d>d :call ddu#start({"name": "lsp_definition"})<CR>
nnoremap <C-d>r :call ddu#start({"name": "lsp_references"})<CR>
