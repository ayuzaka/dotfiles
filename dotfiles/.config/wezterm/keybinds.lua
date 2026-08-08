local wezterm = require 'wezterm'
local act = wezterm.action
local active_panes = {}
local editprompt = wezterm.home_dir .. '/.local/share/mise/shims/editprompt'
local herdr = wezterm.home_dir .. '/.local/share/mise/shims/herdr'
local xdg_environment = {
  PATH = wezterm.home_dir .. '/.local/share/mise/shims:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin',
  XDG_CACHE_HOME = wezterm.home_dir .. '/.cache',
  XDG_CONFIG_HOME = wezterm.home_dir .. '/.config',
  XDG_DATA_HOME = wezterm.home_dir .. '/.local/share',
  XDG_STATE_HOME = wezterm.home_dir .. '/.local/state',
}

local function editprompt_pane_path(target_pane_id)
  return xdg_environment.XDG_CACHE_HOME .. '/editprompt/wezterm-pane-' .. target_pane_id
end

wezterm.on('update-right-status', function(window, pane)
  window:set_right_status(window:active_workspace())

  local window_id = window:window_id()
  local pane_id = pane:pane_id()
  if active_panes[window_id] == pane_id then
    return
  end
  active_panes[window_id] = pane_id

  local workspace_id = pane:get_user_vars().HERDR_WORKSPACE_ID
  if workspace_id and workspace_id ~= '' then
    wezterm.background_child_process {
      herdr,
      '--session',
      'agents',
      'workspace',
      'focus',
      workspace_id,
    }
  end
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
      key = 'y',
      mods = 'LEADER',
      action = act.ActivateCopyMode,
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
      key = "q",
      mods = "ALT",
      action = wezterm.action_callback(function(window, pane)
        local target_pane_id = tostring(pane:pane_id())
        local pane_file = io.open(editprompt_pane_path(target_pane_id), 'r')
        if pane_file then
          local editor_pane_id = tonumber(pane_file:read('*l'))
          pane_file:close()
          local pane_exists, editor_pane = pcall(wezterm.mux.get_pane, editor_pane_id)
          if pane_exists and editor_pane then
            editor_pane:activate()
            return
          end
        end

        window:perform_action(
          act.SplitPane {
            direction = 'Down',
            size = { Cells = 10 },
            command = {
              args = {
                editprompt,
                'open',
                '--editor',
                'nvim',
                '--always-copy',
                '--mux',
                'wezterm',
                '--target-pane',
                target_pane_id,
                '--env',
                'EDITPROMPT_WEZTERM_TARGET_PANE=' .. target_pane_id,
              },
              set_environment_variables = xdg_environment,
            },
          },
          pane
        )
      end),
    },
    {
      key = 'j',
      mods = 'CTRL',
      action = act.DisableDefaultAssignment,
    },
    {
      key = 's',
      mods = 'LEADER',
      action = wezterm.action_callback(function(window, pane)
        local workspaces = wezterm.mux.get_workspace_names()
        local choices = {}
        for _, name in ipairs(workspaces) do
          table.insert(choices, { label = name })
        end

        window:perform_action(act.InputSelector {
          title = 'Switch workspace',
          choices = choices,
          fuzzy = true,
          action = wezterm.action_callback(function(inner_window, inner_pane, _, label)
            if label then
              inner_window:perform_action(act.SwitchToWorkspace { name = label }, inner_pane)
            end
          end)
        }, pane)
      end),
    },
    {
      key = 'y',
      mods = 'CTRL|SHIFT',
      action = act.PromptInputLine {
        description = wezterm.format {
          { Attribute = { Intensity = 'Bold' } },
          { Foreground = { AnsiColor = 'Fuchsia' } },
          { Text = 'Enter name for new workspace' },
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
      key = 'r',
      mods = 'CTRL|SHIFT',
      action = act.PromptInputLine {
        description = wezterm.format {
          { Attribute = { Intensity = 'Bold' } },
          { Foreground = { AnsiColor = 'Fuchsia' } },
          { Text = 'Enter new name for workspace' },
        },
        action = wezterm.action_callback(function(window, pane, line)
          if line then
            local current = window:active_workspace()
            wezterm.mux.rename_workspace(current, line)
          end
        end)
      },
    },
    {
      key = 'r',
      mods = 'LEADER',
      action = act.ReloadConfiguration,
    },
    {
      key = 'g',
      mods = 'LEADER',
      action = wezterm.action_callback(function(window, pane)
        -- Get ghq root directory
        local root_handle = io.popen('zsh -ic "ghq root"')
        if not root_handle then
          return
        end
        local ghq_root = root_handle:read('*l') or (wezterm.home_dir .. '/workspace')
        root_handle:close()

        local handle = io.popen('zsh -ic "ghq list"')
        if not handle then
          return
        end
        local stdout = handle:read('*a')
        handle:close()

        local choices = {}
        for line in stdout:gmatch('[^\n]+') do
          local ws_name = line:match('([^/]+/[^/]+)$') or line
          table.insert(choices, {
            id = line,
            label = ws_name,
          })
        end

        window:perform_action(act.InputSelector {
          title = 'Select ghq project',
          choices = choices,
          fuzzy = true,
          action = wezterm.action_callback(function(inner_window, inner_pane, id, label)
            local repo = id or label
            if not repo then
              return
            end
            local ws_name = label or (repo:match('([^/]+/[^/]+)$') or repo)
            local project_path = ghq_root .. '/' .. repo
            inner_window:perform_action(act.SwitchToWorkspace {
              name = ws_name,
              spawn = { cwd = project_path }
            }, inner_pane)
          end)
        }, pane)
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
