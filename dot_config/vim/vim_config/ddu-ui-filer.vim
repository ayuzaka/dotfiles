UsePlugin 'ddu-ui-filer'

autocmd TabEnter,CursorHold,FocusGained <buffer>
	\ call ddu#ui#do_action('checkItems')

autocmd FileType ddu-filer call s:ddu_filer_my_settings()

function! s:ddu_filer_my_settings() abort
  nnoremap <buffer><silent><expr> <CR>
    \ ddu#ui#get_item()->get('isTree', v:false) ?
    \ "<Cmd>call ddu#ui#do_action('itemAction', {'name': 'narrow'})<CR>" :
    \ "<Cmd>call ddu#ui#do_action('itemAction', {'name': 'open', 'params': {'command': 'rightbelow vsplit'}})<CR>"

  nnoremap <buffer><silent> <Space>
        \ <Cmd>call ddu#ui#do_action('toggleSelectItem')<CR>

  nnoremap <buffer><silent> p
        \ <Cmd>call ddu#ui#do_action('preview')<CR>

  nnoremap <buffer><silent> q
    \ <Cmd>close<CR>

  nnoremap <buffer><silent> ..
        \ <Cmd>call ddu#ui#do_action('itemAction', { 'name': 'narrow', 'params': { 'path': '..' } })<CR>

  nnoremap <buffer><silent> t
    \ <Cmd>call ddu#ui#do_action('itemAction', { 'name': 'newFile' })<CR>

  nnoremap <buffer><silent> mk
    \ <Cmd>call ddu#ui#do_action('itemAction', { 'name': 'newDirectory' })<CR>

  nnoremap <buffer><silent> r
    \ <Cmd>call ddu#ui#do_action('itemAction', { 'name': 'rename' })<CR>

  nnoremap <buffer><silent> d
    \ <Cmd>call ddu#ui#do_action('itemAction', { 'name': 'delete' })<CR>

  nnoremap <buffer><silent><expr> l
        \ ddu#ui#get_item()->get('isTree', v:false) ?
        \ "<Cmd>call ddu#ui#do_action('expandItem', {'mode': 'toggle'})<CR>" :
        \ "<Cmd>call ddu#ui#do_action('itemAction', { 'name': 'open', 'params': { 'command': 'rightbelow vsplit' } })<CR>"
endfunction

call ddu#custom#patch_local('filer', #{
      \  ui: 'filer',
      \  sources: [#{
      \    name: 'file',
      \    params: {},
      \  }],
      \  sourceOptions: #{
      \    _: #{
      \      columns: ['filename'],
      \    },
      \  },
      \  uiParams: #{
      \    filer: #{
      \      displayRoot: v:false,
      \      statusline: v:false,
      \      winWidth: 40,
      \      split: 'vertical',
      \      splitDirection: 'topleft',
      \      previewSplit: 'vertical',
      \      sort: 'filename',
      \    },
      \  },
      \  actionOptions: #{
      \    open: #{
      \      quit: v:false,
      \    }
      \  }
      \})

command! Filer call ddu#start(#{
    \  name: 'filer',
    \})
