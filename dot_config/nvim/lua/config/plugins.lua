-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- Immediate loading (required for first render)
  {
    "morhetz/gruvbox",
    lazy = false,
    priority = 1000,
    config = function() require("plugins.gruvbox") end
  },
  { "neovim/nvim-lspconfig", lazy = false },
  { "tani/vim-artemis",      lazy = false },

  -- BufReadPost / VeryLazy (on edit start)
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function() require("plugins.nvim-treesitter") end
  },
  {
    "lewis6991/gitsigns.nvim",
    event = "BufReadPost",
    config = function() require("plugins.gitsigns") end
  },
  { "nvim-tree/nvim-web-devicons", lazy = true },
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function() require("plugins.lualine") end
  },
  { "andymass/vim-matchup",        event = "BufReadPost" },

  {
    "johmsalas/text-case.nvim",
    event = "BufReadPost",
    config = function() require("plugins.text-case") end
  },
  {
    "Bakudankun/BackAndForward.vim",
    event = "BufReadPost",
    config = function() require("plugins.BackAndForward") end
  },
  { "machakann/vim-sandwich",    event = "BufReadPost" },
  { "easymotion/vim-easymotion", event = "BufReadPost" },
  { "bullets-vim/bullets.vim",   event = "BufReadPost" },
  { "cohama/lexima.vim",         event = "InsertEnter" },
  { "folke/ts-comments.nvim",    event = "VeryLazy" },
  { "cocopon/iceberg.vim",       event = "VeryLazy" },

  -- Command / FileType
  {
    "sbdchd/neoformat",
    cmd = { "Neoformat", "Prettier", "BiomeFormat", "FixJson", "SQLFormatter" },
    config = function()
      vim.api.nvim_create_user_command("Prettier", "Neoformat prettier", {})
      vim.api.nvim_create_user_command("BiomeFormat", "Neoformat biome", {})
      vim.api.nvim_create_user_command("FixJson", "Neoformat fixjson", {})
      vim.api.nvim_create_user_command("SQLFormatter", "Neoformat sqlformatter", {})
    end
  },
  {
    "nanotee/sqls.nvim",
    ft = "sql",
    config = function() require("plugins.sqls") end
  },
  { "mattn/emmet-vim",        ft = { "html", "css", "vue", "svelte", "javascriptreact", "typescriptreact" } },
  { "godlygeek/tabular" },
  { "preservim/vim-markdown", ft = "markdown" },
  { "imsnif/kdl.vim",         ft = "kdl" },
  {
    "3rd/image.nvim",
    event = "VeryLazy",
    build = false,
    config = function() require("plugins.image") end
  },
  {
    "barrett-ruth/import-cost.nvim",
    build = "sh install.sh npm",
    ft = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
    config = function() require("plugins.import-cost") end
  },

  -- Test runner
  { "nvim-neotest/nvim-nio",     lazy = true },
  { "marilari88/neotest-vitest", lazy = true },
  {
    "nvim-neotest/neotest",
    event = "VeryLazy",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "marilari88/neotest-vitest",
    },
    config = function() require("plugins.neotest") end
  },
  {
    "moonbit-community/moonbit.nvim",
    ft = "moonbit",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {
      mooncakes = {
        virtual_text = true, -- virtual text showing suggestions
        use_local = true,    -- recommended, use index under ~/.moon
      },
      treesitter = { enabled = true, auto_install = true },
      lsp = {
        on_attach = function() end,
        capabilities = vim.lsp.protocol.make_client_capabilities(),
      }
    }
  },
  -- denops ecosystem (deferred Deno runtime startup)
  { "vim-denops/denops.vim",               event = "VeryLazy" },
  { "Shougo/pum.vim",                      event = "VeryLazy" },
  { "Shougo/ddc.vim",                      event = "VeryLazy" },
  { "Shougo/ddc-ui-native",                event = "VeryLazy" },
  { "Shougo/ddc-ui-pum",                   event = "VeryLazy" },
  { "Shougo/ddc-matcher_head",             event = "VeryLazy" },
  { "Shougo/ddc-sorter_rank",              event = "VeryLazy" },
  { "Shougo/ddc-source-lsp",               event = "VeryLazy" },
  { "LumaKernel/ddc-source-file",          event = "VeryLazy" },
  { "tani/ddc-fuzzy",                      event = "VeryLazy" },
  { "vim-skk/skkeleton",                   event = "VeryLazy" },
  { "Shougo/ddu.vim",                      event = "VeryLazy" },
  { "Shougo/ddu-ui-ff",                    event = "VeryLazy" },
  { "Shougo/ddu-source-file_rec",          event = "VeryLazy" },
  { "matsui54/ddu-source-file_external",   event = "VeryLazy" },
  { "uga-rosa/ddu-source-lsp",             event = "VeryLazy" },
  { "shun/ddu-source-rg",                  event = "VeryLazy" },
  { "shun/ddu-source-buffer",              event = "VeryLazy" },
  { "Shougo/ddu-source-file",              event = "VeryLazy" },
  { "Shougo/ddu-kind-file",                event = "VeryLazy" },
  { "Shougo/ddu-filter-matcher_substring", event = "VeryLazy" },
  { "matsui54/ddu-source-help",            event = "VeryLazy" },
  { "kuuote/ddu-source-git_status",        event = "VeryLazy" },
  { "kyoh86/ddu-source-git_log",           event = "VeryLazy" },
  { "ayuzaka/ddu-source-gh_pr_diff",       event = "VeryLazy" },
  { "ayuzaka/ddu-source-marks",            event = "VeryLazy" },
  { "Shougo/ddu-ui-filer",                 event = "VeryLazy" },
  { "ryota2357/ddu-column-icon_filename",  event = "VeryLazy" },
  { "Shougo/ddu-column-filename",          event = "VeryLazy" },
})

-- Immediate config
require("config.float-term")
require("config.marks")

-- vim.g settings (must be set before plugin loads)
require("plugins.vim-matchup")
require("plugins.vim-markdown")
require("plugins.bullets")
require("plugins.emmet")
require("plugins.neoformat")

-- denops ecosystem: configure after DenopsReady
vim.api.nvim_create_autocmd("User", {
  pattern = "DenopsReady",
  once = true,
  callback = function()
    require("plugins.denops")
    require("plugins.pum")
    require("plugins.skkeleton")
    require("plugins.ddc")
    require("plugins.ddu")
    require("plugins.ddu-keymaps")
    require("plugins.ddu-source-buffer")
    require("plugins.ddu-source")
    require("plugins.ddu-source-lsp")
    require("plugins.ddu-source-git_log")
    require("plugins.ddu-source-git_status")
    require("plugins.ddu-source-rg")
    require("plugins.ddu-source-gh_pr_diff")
    require("plugins.ddu-source-marks")
    require("plugins.ddu-ui-filer")
  end,
})
