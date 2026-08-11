local du = require("md-render.display_utils")
local orig_open = du.open_float_window
du.open_float_window = function(buf, content, float_win, opts)
  local win = orig_open(buf, content, float_win, opts)
  local w = math.floor(vim.o.columns * 0.8)
  local h = math.min(#content.lines, math.floor(vim.o.lines * 0.8))
  local r = math.max(0, math.floor((vim.o.lines - h) / 2) - 1)
  local c = math.max(0, math.floor((vim.o.columns - w) / 2))
  vim.api.nvim_win_set_config(win, { relative = "editor", width = w, height = h, row = r, col = c })
  return win
end

local preview = require("md-render.preview")
local orig_show = preview.show
preview.show = function(opts)
  opts = opts or {}
  opts.max_width = opts.max_width or (math.floor(vim.o.columns * 0.8) - 4)
  return orig_show(opts)
end
