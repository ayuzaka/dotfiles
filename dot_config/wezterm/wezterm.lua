local wezterm = require "wezterm"
local keybinds = require("keybinds")
local font_list = require("font_list")

local resolve_font = function()
  local ok, font_local = pcall(dofile, wezterm.config_dir .. "/font_list.lua")
  if ok and type(font_local) == "table" then
    return font_local
  end

  return font_list
end


local resolved_font = resolve_font()

wezterm.on("format-tab-title", function(tab)
  local pane = tab.active_pane
  local cwd = pane.current_working_dir
  if cwd then
    local dir = cwd.file_path:match("([^/]+)$") or cwd.file_path
    return " " .. dir .. " "
  end
  return pane.title
end)

local function read_theme()
  local f = io.open(os.getenv("HOME") .. "/.config/theme", "r")
  if f then
    local theme = f:read("*l")
    f:close()
    return theme and theme:match("^%s*(.-)%s*$") or "dark"
  end
  return "dark"
end

local function scheme_for_theme(theme)
  if theme == "dark" then
    return "Everforest Dark (Gogh)"
  else
    return "Everforest Light (Gogh)"
  end
end

local tab_bar_colors = {
  dark = {
    background = "#2d353b",
    active_tab   = { bg_color = "#a7c080", fg_color = "#2d353b" },
    inactive_tab = { bg_color = "#343f44", fg_color = "#9da9a0" },
    inactive_tab_hover = { bg_color = "#3d484d", fg_color = "#d3c6aa" },
    new_tab       = { bg_color = "#2d353b", fg_color = "#9da9a0" },
    new_tab_hover = { bg_color = "#343f44", fg_color = "#d3c6aa" },
  },
  light = {
    background = "#e5e0d8",
    active_tab   = { bg_color = "#8da101", fg_color = "#f3efe4" },
    inactive_tab = { bg_color = "#d4cfc8", fg_color = "#5c6a72" },
    inactive_tab_hover = { bg_color = "#c9c4bd", fg_color = "#5c6a72" },
    new_tab       = { bg_color = "#e5e0d8", fg_color = "#859289" },
    new_tab_hover = { bg_color = "#d4cfc8", fg_color = "#5c6a72" },
  },
}

local theme = read_theme()

return {
  color_scheme = scheme_for_theme(theme),
  colors = { tab_bar = tab_bar_colors[theme] },
  font = wezterm.font_with_fallback(resolved_font.font),
  font_size = resolved_font.font_size,
  use_ime = true,
  macos_forward_to_ime_modifier_mask = "SHIFT|CTRL",
  hide_tab_bar_if_only_one_tab = true,
  tab_bar_at_bottom = true,
  use_fancy_tab_bar = false,
  show_new_tab_button_in_tab_bar = false,
  window_decorations = "RESIZE",
  disable_default_key_bindings = true,
  audible_bell = "SystemBeep",
  leader = keybinds.leader,
  keys = keybinds.keys,
}
