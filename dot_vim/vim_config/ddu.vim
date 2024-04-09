UsePlugin 'ddu.vim'

call ddu#custom#patch_global({
    \   'ui': 'ff',
    \   'sourceOptions': {
    \     '_': {
    \       'matchers': ['matcher_substring'],
    \     },
    \   },
    \   'kindOptions': {
    \     'file': {
    \       'defaultAction': 'open',
    \     },
    \   },
    \ })

 call ddu#custom#patch_local('git-files', {
    \   'sources': [{'name': 'file_external', 'params': {}}],
    \   'sourceParams': {
    \     'file_external': {
    \       'cmd': ['git', 'ls-files']
    \     },
    \   },
    \ })

 call ddu#custom#patch_local('grep', {
    \   'sources': [{'name': 'file_external', 'params': {}}],
    \   'sourceParams': #{
    \     rg: #{
    \       args: ['--column', '--no-heading', '--color', 'never']
    \     },
    \   },
    \ })

autocmd FileType ddu-ff call s:ddu_my_settings()
autocmd FileType ddu-filer call s:ddu_my_settings()

function! s:ddu_my_settings() abort
  nnoremap <buffer><silent> <CR>
        \ <Cmd>call ddu#ui#do_action('itemAction')<CR>
  nnoremap <buffer><silent> <Space>
        \ <Cmd>call ddu#ui#do_action('toggleSelectItem')<CR>
  nnoremap <buffer><silent> i
        \ <Cmd>call ddu#ui#do_action('openFilterWindow')<CR>
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

nnoremap <C-p> :call ddu#start({"name": "git-files"})<CR>
command! DduGrep :call ddu#start({
      \  'name': 'grep',
      \  'sources': [
      \    { 'name': 'rg', 'params': { 'input': expand('<cword>') } }
      \  ],
      \ })
