vim.cmd("packadd vim-jetpack")
require("jetpack.packer").add {
  -- Immediate loading (required for first render)
  { "tani/vim-jetpack" },
  { "tani/vim-artemis" },
  { "morhetz/gruvbox" },
  { "neovim/nvim-lspconfig" },

  -- BufReadPost / VeryLazy (on edit start)
  { "nvim-treesitter/nvim-treesitter", branch = "main", event = "BufReadPost",
    config = function() require("plugins.nvim-treesitter") end },
  { "lewis6991/gitsigns.nvim", event = "BufReadPost",
    config = function() require("plugins.gitsigns") end },
  { "nvim-lualine/lualine.nvim", event = "VeryLazy",
    config = function() require("plugins.lualine") end },
  { "andymass/vim-matchup", event = "BufReadPost" },
  { "chentoast/marks.nvim", event = "BufReadPost",
    config = function() require("plugins.marks") end },
  { "johmsalas/text-case.nvim", event = "BufReadPost",
    config = function() require("plugins.text-case") end },
  { "Bakudankun/BackAndForward.vim", event = "BufReadPost" },
  { "machakann/vim-sandwich", event = "BufReadPost" },
  { "easymotion/vim-easymotion", event = "BufReadPost" },
  { "bullets-vim/bullets.vim", event = "BufReadPost" },
  { "cohama/lexima.vim", event = "InsertEnter" },
  { "folke/ts-comments.nvim", event = "VeryLazy" },
  { "vim-jp/nvimdoc-ja", event = "VeryLazy" },
  { "cocopon/iceberg.vim", event = "VeryLazy" },

  -- Command / FileType
  { "nvim-lua/plenary.nvim", event = "VeryLazy" },
  { "nvim-telescope/telescope.nvim", cmd = "Telescope",
    config = function() require("plugins.telescope") end },
  { "sbdchd/neoformat", cmd = { "Neoformat", "Prettier", "BiomeFormat", "FixJson", "SQLFormatter" },
    config = function()
      vim.api.nvim_create_user_command("Prettier", "Neoformat prettier", {})
      vim.api.nvim_create_user_command("BiomeFormat", "Neoformat biome", {})
      vim.api.nvim_create_user_command("FixJson", "Neoformat fixjson", {})
      vim.api.nvim_create_user_command("SQLFormatter", "Neoformat sqlformatter", {})
    end },
  { "nanotee/sqls.nvim", ft = "sql",
    config = function() require("plugins.sqls") end },
  { "mattn/emmet-vim", ft = { "html", "css", "vue", "svelte", "javascriptreact", "typescriptreact" } },
  { "godlygeek/tabular" },
  { "preservim/vim-markdown", ft = "markdown" },
  { "imsnif/kdl.vim", ft = "kdl" },
  { "3rd/image.nvim", event = "VeryLazy",
    config = function() require("plugins.image") end },
  { "barrett-ruth/import-cost.nvim", build = "sh install.sh npm",
    ft = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
    config = function() require("plugins.import-cost") end },

  -- Test runner
  { "nvim-neotest/nvim-nio", event = "VeryLazy" },
  { "nvim-neotest/neotest", event = "VeryLazy",
    config = function() require("plugins.neotest") end },
  { "marilari88/neotest-vitest", event = "VeryLazy" },

  -- denops ecosystem (deferred Deno runtime startup)
  { "vim-denops/denops.vim", event = "VeryLazy" },
  { "Shougo/pum.vim", event = "VeryLazy" },
  { "Shougo/ddc.vim", event = "VeryLazy" },
  { "Shougo/ddc-ui-native", event = "VeryLazy" },
  { "Shougo/ddc-ui-pum", event = "VeryLazy" },
  { "Shougo/ddc-matcher_head", event = "VeryLazy" },
  { "Shougo/ddc-sorter_rank", event = "VeryLazy" },
  { "shun/ddc-source-vim-lsp", event = "VeryLazy" },
  { "LumaKernel/ddc-source-file", event = "VeryLazy" },
  { "tani/ddc-fuzzy", event = "VeryLazy" },
  { "vim-skk/skkeleton", event = "VeryLazy" },
  { "Shougo/ddu.vim", event = "VeryLazy" },
  { "Shougo/ddu-ui-ff", event = "VeryLazy" },
  { "Shougo/ddu-source-file_rec", event = "VeryLazy" },
  { "matsui54/ddu-source-file_external", event = "VeryLazy" },
  { "uga-rosa/ddu-source-lsp", event = "VeryLazy" },
  { "shun/ddu-source-rg", event = "VeryLazy" },
  { "shun/ddu-source-buffer", event = "VeryLazy" },
  { "Shougo/ddu-source-file", event = "VeryLazy" },
  { "Shougo/ddu-kind-file", event = "VeryLazy" },
  { "Shougo/ddu-filter-matcher_substring", event = "VeryLazy" },
  { "matsui54/ddu-source-help", event = "VeryLazy" },
  { "kuuote/ddu-source-git_status", event = "VeryLazy" },
  { "kyoh86/ddu-source-git_log", event = "VeryLazy" },
  { "ayuzaka/ddu-source-gh_pr_diff", event = "VeryLazy" },
  { "ayuzaka/ddu-source-marks", event = "VeryLazy" },
  { "Shougo/ddu-ui-filer", event = "VeryLazy" },
  { "ryota2357/ddu-column-icon_filename", event = "VeryLazy" },
  { "Shougo/ddu-column-filename", event = "VeryLazy" },
}

-- Immediate config
require("plugins.gruvbox")
require("config.float-term")

-- vim.g settings (must be set before plugin loads)
require("plugins.vim-matchup")
require("plugins.vim-markdown")
require("plugins.bullets")
require("plugins.emmet")
require("plugins.neoformat")

-- VimScript plugins deferred to VimEnter
-- jetpack's event option does not work for VimScript plugins when files
-- are opened at startup (BufReadPost fires before VimEnter, causing
-- jetpack#load_plugin to defer to JetpackPre:init which already fired).
-- Lua plugins work because their config callbacks use require().
vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    local vimscript_plugins = {
      "vim-matchup",
      "vim-sandwich",
      "vim-easymotion",
      "BackAndForward.vim",
      "bullets.vim",
    }
    for _, name in ipairs(vimscript_plugins) do
      vim.cmd("packadd " .. name)
    end
    require("plugins.BackAndForward")
    vim.cmd("doautocmd FileType")
  end,
})

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
