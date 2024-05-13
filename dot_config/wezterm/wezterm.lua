local wezterm = require 'wezterm'
local keybinds = require('keybinds')

return {
  color_scheme = "GruvboxDark",
  font = wezterm.font("Moralerspace Argon NF", { weight = 'Regular' }),
  use_ime = true,
  hide_tab_bar_if_only_one_tab = true,
  tab_bar_at_bottom = true,
  disable_default_key_bindings = true,
  leader = keybinds.leader,
  keys = keybinds.keys,
}
