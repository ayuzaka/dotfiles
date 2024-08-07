UsePlugin 'vim-lsp'

let g:lsp_log_file = ''

function! s:on_lsp_buffer_enabled() abort
    setlocal omnifunc=lsp#complete
    setlocal signcolumn=yes
    if exists('+tagfunc') | setlocal tagfunc=lsp#tagfunc | endif
    nmap <buffer> gd <plug>(lsp-definition)
    nmap <buffer> gr <plug>(lsp-references)
    nmap <buffer> gi <plug>(lsp-implementation)
    nmap <buffer> gt <plug>(lsp-type-definition)
    nmap <buffer> <leader>rn <plug>(lsp-rename)
    nmap <buffer> [g <Plug>(lsp-previous-diagnostic)
    nmap <buffer> ]g <Plug>(lsp-next-diagnostic)
    nmap <buffer> K <plug>(lsp-hover)
    nnoremap <expr><buffer> <c-f> popup_list()->empty() ? '<c-f>' : lsp#scroll(+4)
    nnoremap <expr><buffer> <c-b> popup_list()->empty() ? '<c-b>' : lsp#scroll(-4)

    " refer to doc to add more commands
endfunction

augroup lsp_install
    au!
    " call s:on_lsp_buffer_enabled only for languages that has the server registered.
    autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END

augroup vim_lsp_golangci_lint_langserver
  au!
  autocmd User lsp_setup call lsp#register_server({
      \ 'name': 'golangci-lint-langserver',
      \ 'cmd': {server_info->['golangci-lint-langserver']},
      \ 'initialization_options': {'command': ['golangci-lint', 'run', '--out-format', 'json', '--issues-exit-code=1', '--config', '~/.config/golangci-lint/.golangci.yaml']},
      \ 'allowlist': ['go'],
      \ })
augroup END

nnoremap <silent>fmt :LspDocumentFormat<CR>
command! EfmFormat :LspDocumentFormatSync --server=efm-langserver
let g:lsp_signs_enabled = 1
let g:lsp_document_code_action_signs_enabled = 0
let g:lsp_diagnostics_echo_cursor = 1
let g:lsp_diagnostics_echo_delay = 50
let g:lsp_diagnostics_highlights_insert_mode_enabled = 0
let g:lsp_diagnostics_highlights_delay = 50
let g:lsp_diagnostics_signs_delay = 50
let g:lsp_diagnostics_signs_insert_mode_enabled = 0
let g:lsp_diagnostics_virtual_text_delay = 50
let lsp_diagnostics_virtual_text_enabled = 0
let g:lsp_completion_documentation_delay = 40
let g:lsp_document_highlight_delay = 100
let g:lsp_document_code_action_signs_delay = 100
let g:lsp_settings_filetype_javascript = ['typescript-language-server', 'eslint-language-server']
let g:lsp_settings_filetype_typescript = ['typescript-language-server', 'eslint-language-server', 'deno', 'biome']
let g:lsp_settings_filetype_typescriptreact = ['typescript-language-server', 'eslint-language-server', 'deno', 'biome']
let g:lsp_settings_filetype_html = ['html-languageserver', 'tailwindcss-intellisense']
let g:lsp_settings_filetype_css = ['css-languageserver', 'tailwindcss-intellisense']
let g:lsp_settings_filetype_svelte = ['svelte-language-server', 'eslint-language-server']
let g:lsp_settings = {
      \ 'efm-langserver': {
      \     'disabled': 0,
      \     'allowlist': ['*'],
      \   },
      \  'biome': {
      \     'disabled': 1,
      \     'allowlist': ['typescript', 'typescriptreact'],
      \  }
      \ }

function! s:eslint_fix() abort
  execute '!bunx eslint --fix "%"'
  execute 'LspStopServer'
endfunction
command! ESLintFix call s:eslint_fix()

function! s:stylelint_fix() abort
  execute '!bunx stylelint --fix "%"'
  execute 'LspStopServer'
endfunction
command! StylelintFix call s:stylelint_fix()

