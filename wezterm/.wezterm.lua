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

-- and finally, return the configuration to wezterm
return config