local wezterm = require "wezterm"
local keybinds = require("keybinds")
local font_list = require "font_list"

local resolve_font = function()
  local ok, font_local = pcall(dofile, wezterm.config_dir .. "/font_local.lua")
  if ok and type(font_local) == "table" then
    return font_local
  end

  return font_list
end

return {
  color_scheme = "GruvboxDark",
  font = wezterm.font_with_fallback(resolve_font()),
  use_ime = true,
  macos_forward_to_ime_modifier_mask = "SHIFT|CTRL",
  hide_tab_bar_if_only_one_tab = true,
  tab_bar_at_bottom = true,
  show_new_tab_button_in_tab_bar = false,
  window_decorations = "RESIZE",
  disable_default_key_bindings = true,
  audible_bell = "SystemBeep",
  leader = keybinds.leader,
  keys = keybinds.keys,
}
