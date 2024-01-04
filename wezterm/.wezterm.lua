-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- This is where you actually apply your config choices

config.window_close_confirmation = 'NeverPrompt'

config.default_prog = { 'zsh', '-lis', 'eval', 'zellij attach main -c' }

config.enable_tab_bar = false
config.window_padding = {
  left = 2,
  right = 2,
  top = 2,
  bottom = 0,
}

config.font_size = 13.0
config.font = wezterm.font {
  family = 'FiraCode Nerd Font',
  weight = 'Regular',
}

config.color_scheme_dirs = { '/Users/ben.bachem/Documents/Dev/dotfiles/wezterm/themes' }
config.color_scheme = 'concrete'

config.keys = {
   -- Make Option-Left equivalent to Alt-b which many line editors interpret as backward-word
  {key="LeftArrow", mods="OPT", action=wezterm.action{SendString="\x1bb"}},
  
  -- Make Option-Right equivalent to Alt-f; forward-word
  {key="RightArrow", mods="OPT", action=wezterm.action{SendString="\x1bf"}},
}

-- and finally, return the configuration to wezterm
return config