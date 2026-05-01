local function sqls_status()
  return vim.g.sqls_current_connection or ""
end

require('lualine').setup {
  options = {
    icons_enabled = true,
    theme = 'auto',
    component_separators = { left = '', right = '' },
    section_separators = { left = '', right = '' },
    disabled_filetypes = {
      statusline = {},
      winbar = {},
    },
    ignore_focus = {},
    always_divide_middle = true,
    always_show_tabline = true,
    globalstatus = false,
    refresh = {
      statusline = 100,
      tabline = 100,
      winbar = 100,
    }
  },
  sections = {
    lualine_a = {},
    lualine_b = { 'branch', 'diff', 'diagnostics' },
    lualine_c = {
      { 'filename', path = 1 }
    },
    lualine_x = {
      {
        sqls_status,
        icon = '󰆼',
        color = 'lualine_b_normal',
        cond = function()
          return vim.bo.filetype == "sql" and vim.g.sqls_current_connection ~= nil
        end,
      },
    },
    lualine_y = {},
    lualine_z = {},
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {},
    lualine_x = {},
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {
    lualine_a = {
      { 'filename', path = 1 }
    },
  },
  winbar = {},
  inactive_winbar = {},
  extensions = {}
}
