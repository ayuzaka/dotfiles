vim.cmd("packadd vim-jetpack")
require("jetpack.packer").add {
  { "tani/vim-jetpack" },
  { "tani/vim-artemis" },
  { "morhetz/gruvbox" },
  { "nvim-treesitter/nvim-treesitter", branch  = "main" },
  { "andymass/vim-matchup" },
  { "vim-denops/denops.vim" },
  { "nvim-lua/plenary.nvim" },
  { "azorng/goose.nvim" },
  { "nvim-telescope/telescope.nvim" },
  { "neovim/nvim-lspconfig" },
  { "sbdchd/neoformat" },
  { "Shougo/pum.vim" },
  { "Shougo/ddc.vim" },
  { "Shougo/ddc-ui-native" },
  { "Shougo/ddc-ui-pum" },
  { "Shougo/ddc-matcher_head" },
  { "Shougo/ddc-sorter_rank" },
  { "shun/ddc-source-vim-lsp" },
  { "tani/ddc-fuzzy" },
  { "Shougo/ddu.vim" },
  { "Shougo/ddu-ui-ff" },
  { "Shougo/ddu-source-file_rec" },
  { "matsui54/ddu-source-file_external" },
  { "uga-rosa/ddu-source-lsp" },
  { "shun/ddu-source-rg" },
  { "shun/ddu-source-buffer" },
  { "Shougo/ddu-source-file" },
  { "Shougo/ddu-kind-file" },
  { "Shougo/ddu-filter-matcher_substring" },
  { "matsui54/ddu-source-help" },
  { "kuuote/ddu-source-git_status" },
  { "kyoh86/ddu-source-git_log" },
  { "Shougo/ddu-ui-filer" },
  { "ryota2357/ddu-column-icon_filename" },
  { "Shougo/ddu-column-filename" },
  { 'nvim-lualine/lualine.nvim' },
  { "easymotion/vim-easymotion" },
  { "cohama/lexima.vim" },
  { "lewis6991/gitsigns.nvim" },
  { "godlygeek/tabular" },
  { "mattn/emmet-vim" },
  { "preservim/vim-markdown" },
  { "bullets-vim/bullets.vim" },
  { "imsnif/kdl.vim" },
  { "machakann/vim-sandwich" },
  { "folke/ts-comments.nvim", event = "VeryLazy" },
  { "chentoast/marks.nvim" },
  { "akinsho/toggleterm.nvim" },
  { "barrett-ruth/import-cost.nvim", build = "sh install.sh npm" }
}

local function require_all_plugins()
  local plugin_files = vim.fn.glob(vim.fn.stdpath("config") .. "/lua/plugins/*.lua", false, true)

  for _, file in ipairs(plugin_files) do
    -- ファイルパスからモジュール名を抽出
    local module_name = file:match("lua/plugins/(.+).lua$")
    local ok, err = pcall(require, "plugins." .. module_name)
    if not ok then
      vim.notify("Failed to load module: plugins." .. module_name .. "\n" .. err, vim.log.levels.ERROR)
    end
  end
end

require_all_plugins()
