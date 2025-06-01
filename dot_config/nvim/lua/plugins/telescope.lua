require("telescope").setup({
  defaults = {
    mappings = {
      i = {
        ["<C-u>"] = false, -- Disable <C-u> in insert mode
        ["<C-d>"] = false, -- Disable <C-d> in insert mode
      },
    },
  },
  pickers = {
    find_files = {
      themes = "dropdown"
    },
  },
})
