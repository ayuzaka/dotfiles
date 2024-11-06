vim.cmd("packadd vim-jetpack")
require("jetpack.packer").add {
  { "tani/vim-jetpack" },
  { "morhetz/gruvbox" },
  { "vim-denops/denops.vim" },
  { "github/copilot.vim"},
  { "prabirshrestha/vim-lsp" },
  { "mattn/vim-lsp-settings" },
  { 'prabirshrestha/asyncomplete.vim' },
  { 'prabirshrestha/asyncomplete-lsp.vim' },
  { "evanleck/vim-svelte" },
  { "Shougo/ddc.vim"},
  { "Shougo/ddc-ui-native"},
  { "Shougo/ddc-matcher_head"},
  { "Shougo/ddc-sorter_rank"},
  { "Shougo/ddc-source-lsp"},
  { "uga-rosa/ddc-source-lsp-setup" },
  { "Shougo/ddu.vim"},
  { "Shougo/ddu-ui-ff"},
  { "Shougo/ddu-source-file_rec"},
  { "matsui54/ddu-source-file_external"},
  { "uga-rosa/ddu-source-lsp"},
  { "shun/ddu-source-rg"},
  { "Shougo/ddu-source-file"},
  { "Shougo/ddu-kind-file"},
  { "Shougo/ddu-filter-matcher_substring"},
  { "matsui54/ddu-source-help"},
  { "kuuote/ddu-source-git_status"},
  { "Shougo/ddu-ui-filer"},
  { "ryota2357/ddu-column-icon_filename"},
  { "Shougo/ddu-column-filename"},
  { "vim-skk/skkeleton"},
  { "vim-airline/vim-airline"},
  { "vim-airline/vim-airline-themes"},
  { "easymotion/vim-easymotion"},
  { "maxmellon/vim-jsx-pretty"},
  { "leafgarland/typescript-vim"},
  { "cohama/lexima.vim"},
  { "airblade/vim-gitgutter"},
  { "tpope/vim-fugitive"},
  { "godlygeek/tabular"},
  { "preservim/vim-markdown"},
  { "imsnif/kdl.vim"},
  { "machakann/vim-sandwich"},
}

require("plugins.gruvbox")
require("plugins.denops")
require("plugins.vim-lsp")
require("plugins.skkeleton")
require("plugins.ddc")
require("plugins.ddu")
require("plugins.ddu-column-icon_filename")
require("plugins.ddu-source")
require("plugins.ddu-source-rg")
require("plugins.ddu-source-git_status")
require("plugins.ddu-source-lsp")
require("plugins.ddu-ui-filer")
require("plugins.vim-markdown")
require("plugins.vim-airline")
require("plugins.vim-fugitive")
require("plugins.copilot")
