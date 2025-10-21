local wezterm = require 'wezterm'
local act = wezterm.action

wezterm.on('update-right-status', function(window)
  window:set_right_status(window:active_workspace())
end)

local config = {
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
      mods = 'CTRL',
      action = act.IncreaseFontSize,
    },
    {
      key = '0',
      mods = 'LEADER',
      action = act.ResetFontSize,
    },
    {
      key = '-',
      mods = 'CTRL',
      action = wezterm.action.DecreaseFontSize
    },
    {
      key = 'w',
      mods = 'LEADER',
      action = act.CloseCurrentTab { confirm = true },
    },
    {
      key = ',',
      mods = 'LEADER',
      action = act.PromptInputLine {
        description = 'Enter new name for tab',
        action = wezterm.action_callback(function(window, _pane, line)
          if line then
            window:active_tab():set_title(line)
          end
        end),
      },
    },
    {
      key = 'x',
      mods = 'LEADER',
      action = act.CloseCurrentPane { confirm = true },
    },
    {
      key = 'p',
      mods = 'SUPER',
      action = act.CopyTo 'ClipboardAndPrimarySelection',
    },
    {
      key = 'v',
      mods = 'SUPER',
      action = act.PasteFrom 'Clipboard',
    },
    {
      key = 'j',
      mods = 'CTRL',
      action = act.DisableDefaultAssignment,
    },
    {
      key = 's',
      mods = 'LEADER',
      action = act.ShowLauncherArgs {
        flags = 'WORKSPACES',
      },
    },
    {
      key = 'y',
      mods = 'CTRL|SHIFT',
      action = act.PromptInputLine {
        description = wezterm.format {
          { Attribute = { Intensity = 'Bold' } },
          { Foreground = { AnsiColor = 'Fuchsia' } },
          { Text = 'Enter name ofr new workspace' },
        },
        action = wezterm.action_callback(function(window, pane, line)
          if line then
            window:perform_action(
              act.SwitchToWorkspace {
                name = line,
              },
              pane
            )
          end
        end)
      },
    },
    {
      key = "q",
      mods = "OPT",
      action = wezterm.action_callback(function(window, pane)
        local target_pane_id = tostring(pane:pane_id())
        window:perform_action(
          act.SplitPane({
            direction = "Down",
            size = { Cells = 10 },
          }),
          pane
        )
        wezterm.time.call_after(1, function()
          window:perform_action(
            act.SendString(
              string.format(
                "editprompt --editor nvim --always-copy --mux wezterm --target-pane %s\n",
                target_pane_id
              )
            ),
            window:active_pane()
          )
        end)
      end),
    },
  },
}

for i = 1, 8 do
  table.insert(config.keys, {
    key = tostring(i),
    mods = 'LEADER',
    action = act.ActivateTab(i - 1),
  })
end


return config
