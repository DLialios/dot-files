local wezterm = require 'wezterm'
local config = wezterm.config_builder()
local act = wezterm.action

config.disable_default_key_bindings = true

config.font = wezterm.font('Fira Code')
config.font_size = 12

config.enable_scroll_bar = true
config.scrollback_lines = 10000

config.initial_cols = 128
config.initial_rows = 32

config.keys = {
    -- Modes (Command, Copy, Search)
    { key = 'P', mods = 'CTRL', action = act.ActivateCommandPalette, },
    { key = 'X', mods = 'CTRL', action = act.ActivateCopyMode },
    { key = 'F', mods = 'CTRL', action = act.Search { CaseInSensitiveString = '' } },

    -- View
    { key = 'Enter', mods = 'ALT', action = act.ToggleFullScreen },
    { key = '=', mods = 'CTRL', action = act.IncreaseFontSize },
    { key = '-', mods = 'CTRL', action = act.DecreaseFontSize },
    { key = '0', mods = 'CTRL', action = act.ResetFontSize },

    -- Clipboard
    { key = 'C', mods = 'CTRL', action = act.CopyTo 'Clipboard', },
    { key = 'V', mods = 'CTRL', action = act.PasteFrom 'Clipboard' },

    -- MUX: Tabs
    { key = 'T', mods = 'CTRL', action = act.SpawnTab 'CurrentPaneDomain' },
    { key = 'W', mods = 'CTRL', action = act.CloseCurrentTab { confirm = true } },
    { key = 'Tab', mods = 'CTRL|SHIFT', action = act.ActivateTabRelative(-1) },
    { key = 'Tab', mods = 'CTRL', action = act.ActivateTabRelative(1) },

    -- MUX: Panes
    { key = 'B', mods = 'CTRL', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
    { key = 'S', mods = 'CTRL', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },
    { key = 'Z', mods = 'CTRL', action = act.TogglePaneZoomState },

    { key = 'H', mods = 'CTRL', action = act.ActivatePaneDirection('Left') },
    { key = 'J', mods = 'CTRL', action = act.ActivatePaneDirection('Down') },
    { key = 'K', mods = 'CTRL', action = act.ActivatePaneDirection('Up') },
    { key = 'L', mods = 'CTRL', action = act.ActivatePaneDirection('Right') },

    { key = 'LeftArrow', mods = 'CTRL|SHIFT', action = act.AdjustPaneSize { 'Left', 2 } },
    { key = 'RightArrow', mods = 'CTRL|SHIFT', action = act.AdjustPaneSize { 'Right', 2 } },
    { key = 'UpArrow', mods = 'CTRL|SHIFT', action = act.AdjustPaneSize { 'Up', 2 } },
    { key = 'DownArrow', mods = 'CTRL|SHIFT', action = act.AdjustPaneSize { 'Down', 2 } },
}


return config

