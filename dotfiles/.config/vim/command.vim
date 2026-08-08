" ノーマルモードで <Leader>Q を押すと:
" 1. バッファ全体を "+ レジスタ（システムクリップボード）にコピー
" 2. :q! で保存せずに終了
nnoremap <Leader>Q :silent! %y+ <bar> q!<CR>
