UsePlugin 'ddu-source-lsp'

let g:ddu_source_lsp_clientName = 'vim-lsp'
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

command! DduCodeAction :call ddu#start({"name": "codeAction"})
command! DduDef :call ddu#start({"name": "lsp_definition"})
command! DduRef :call ddu#start({"name": "lsp_references"})
