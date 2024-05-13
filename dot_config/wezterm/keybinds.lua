local wezterm = require 'wezterm'
local act = wezterm.action

return {
  leader = { key = 's', mods = 'CTRL', timeout_milliseconds = 1000 },
  keys = {
    {
      key = '|',
      mods = 'LEADER',
      action = act.SplitHorizontal,
    },
    {
      key = '-',
      mods = 'LEADER',
      action = act.SplitVertical,
    },
    {
      key = 'h',
      mods = 'LEADER',
      action = act.ActivatePaneDirection 'Left',
    },
    {
      key = 'j',
      mods = 'LEADER',
      action = act.ActivatePaneDirection 'Down'
    },
    {
      key = 'k',
      mods = 'LEADER',
      action = act.ActivatePaneDirection 'Up',
    },
    {
      key = 'l',
      mods = 'LEADER',
      action = act.ActivatePaneDirection 'Right',
    },
    {
      key = 'z',
      mods = 'LEADER',
      action = act.TogglePaneZoomState,
    },
    {
      key = 'H',
      mods = 'LEADER',
      action = act.AdjustPaneSize { 'Left', 5 },
    },
    {
      key = 'J',
      mods = 'LEADER',
      action = act.AdjustPaneSize { 'Down', 5 },
    },
    {
      key = 'K',
      mods = 'LEADER',
      action = act.AdjustPaneSize { 'Up', 5 },
    },
    {
      key = 'L',
      mods = 'LEADER',
      action = act.AdjustPaneSize { 'Right', 5 },
    },
    {
      key = 't',
      mods = 'LEADER',
      action = act.SpawnCommandInNewTab { cwd = wezterm.home_dir },
    },
    {
      key = '[',
      mods = 'LEADER',
      action = act.ActivateTabRelative(-1),
    },
    {
      key = ']',
      mods = 'LEADER',
      action = act.ActivateTabRelative(1),
    },
    {
      key = '=',
      mods = 'LEADER',
      action = act.IncreaseFontSize,
    },
    {
      key = '0',
      mods = 'LEADER',
      action = act.ResetFontSize,
    },
    {
      key = 'w',
      mods = 'LEADER',
      action = act.CloseCurrentTab { confirm = true },
    },
    {
      key = 'x',
      mods = 'LEADER',
      action = act.CloseCurrentPane { confirm = true },
    },
    {
      key = 'p',
      mods = 'SUPER',
      action = act.CopyTo 'ClipboardAndPrimarySelection'
    },
    {
      key = 'v',
      mods = 'SUPER',
      action = act.PasteFrom 'Clipboard'
    },
    {
      key = 'j',
      mods = 'CTRL',
      action = act.DisableDefaultAssignment,
    },
  },
}

