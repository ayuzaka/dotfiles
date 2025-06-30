UsePlugin 'copilot.vim'

let g:copilot_filetypes = {
      \ 'dotenv': v:false,
      \ }

augroup disableGitHubCopilot
    autocmd!
    autocmd BufRead,BufNewFile $HOME/workspace/ayuzaka/atcoder-go/* execute ":Copilot disable"
    autocmd BufRead,BufNewFile $HOME/workspace/ayuzaka/learn/* execute ":Copilot disable"
    autocmd BufRead,BufNewFile $HOME/Downloads/diary/* execute ":Copilot disable"
    autocmd BufRead,BufNewFile $HOME/Documents/Obsidian\ Vault/* execute ":Copilot disable"
augroup END
