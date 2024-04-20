UsePlugin 'ddu.vim'

call ddu#custom#patch_global(#{
    \   ui: 'ff',
    \   uiParams: #{
    \     ff: #{
    \       ignoreEmpty: v:true,
    \     },
    \   },
    \   sourceOptions: #{
    \     _: #{
    \       matchers: ['matcher_substring'],
    \       ignoreCase: v:true,
    \     },
    \   },
    \   kindOptions: #{
    \     file: #{
    \       defaultAction: 'open',
    \     },
    \     lsp: #{
    \       defaultAction: 'open',
    \     },
    \     lsp_codeAction: #{
    \       defaultAction: 'apply',
    \     },
    \   },
    \ })

call ddu#custom#patch_global(#{
    \   kindOptions: {
    \     'ai-review-request': #{
    \       defaultAction: 'open',
    \     },
    \     'ai-review-log': #{
    \       defaultAction: 'resume',
    \     },
    \   },
    \ })

call ai_review#config({ 'chat_gpt': { 'model': 'gpt-4' } })

call ddu#custom#patch_local('fd', #{
   \   sources: [#{name: 'file_external', params: {}}],
   \   sourceParams: #{
   \     file_external: #{
   \       cmd: ['fd', '.', '-H', '-t', 'f']
   \     },
   \   },
   \ })

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
   \   sources: [#{name: 'lsp_codeAction', params: #{ method: 'textDocument/codeAction' }}],
   \ })

call ddu#custom#patch_local('help', #{
    \   sources: [#{name: 'help'}],
    \   sourceOptions: #{
    \     help: #{
    \       defaultAction: 'open',
    \     },
    \   },
     \})

call ddu#custom#patch_local('git_status', #{
    \  sources: [#{name: 'git_status'}],
    \  kindOptions: #{
    \    git_status: #{
    \      defaultAction: 'open',
    \      actions: #{}
    \    },
    \  },
    \})

autocmd FileType ddu-ff call s:ddu_my_settings()
function! s:ddu_my_settings() abort
  nnoremap <buffer><silent> <CR>
        \ <Cmd>call ddu#ui#do_action('itemAction')<CR>
  nnoremap <buffer><silent> <Space>
        \ <Cmd>call ddu#ui#do_action('toggleSelectItem')<CR>
  nnoremap <buffer><silent> i
        \ <Cmd>call ddu#ui#do_action('openFilterWindow')<CR>
  nnoremap <buffer><silent> p
        \ <Cmd>call ddu#ui#do_action('preview')<CR>
  nnoremap <buffer><silent> q
        \ <Cmd>call ddu#ui#do_action('quit')<CR>
endfunction

autocmd FileType ddu-ff-filter call s:ddu_filter_my_settings()
function! s:ddu_filter_my_settings() abort
  inoremap <buffer><silent> <CR>
  \ <Esc><Cmd>close<CR>
  nnoremap <buffer><silent> <CR>
  \ <Cmd>close<CR>
  nnoremap <buffer><silent> q
  \ <Cmd>close<CR>
endfunction

nnoremap <C-p> :call ddu#start({"name": "fd"})<CR>
command! DduCodeAction :call ddu#start({"name": "codeAction"})
command! DduDef :call ddu#start({"name": "lsp_definition"})
command! DduRef :call ddu#start({"name": "lsp_references"})

command! Grep call ddu_rg#find()
command! Help call ddu#start({"name": "help"})
command! GitStatus call ddu#start({"name": "git_status"})
