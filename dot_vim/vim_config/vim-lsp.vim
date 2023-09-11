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
      \ 'initialization_options': {'command': ['golangci-lint', 'run', '--out-format', 'json', '--issues-exit-code=1']},
      \ 'whitelist': ['go'],
      \ })
augroup END

nmap <silent> fmt :LspDocumentFormat<CR>
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
let g:lsp_settings_filetype_typescript = ['typescript-language-server', 'eslint-language-server', 'deno']
let g:lsp_settings_filetype_typescriptreact = ['typescript-language-server', 'eslint-language-server', 'deno', 'tailwindcss-intellisense']
let g:lsp_settings = {
      \ 'efm-langserver': {
      \     'disabled': 0,
      \     'allowlist': ['markdown', 'javascript', 'typescript' ,'typescriptreact', 'svelte' , 'css', 'scss', 'sh'],
      \   }
      \ }

autocmd BufWritePre *.js,*.jsx,*.ts,*.tsx,*.css,*.scss,*.svelte call execute('LspDocumentFormatSync --server=efm-langserver')

command! ESLintFix {
  :!bunx eslint --fix "%"
  :LspStopServer
}

command! StylelintFix {
  :!bunx stylelint --fix "%"
  :LspStopServer
}
