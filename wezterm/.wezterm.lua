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

config.hyperlink_rules = wezterm.default_hyperlink_rules()

-- make superchat's' linear issues clickable
table.insert(config.hyperlink_rules, {
  regex = [[\b(?:plat|PLAT)-(\d+)]],
  format = 'https://linear.app/superchat/issue/PLAT-$1',
})

-- -- open files in vscode
-- table.insert(config.hyperlink_rules, {
--   regex = [[((?:\w+\/?)+(?:\.\w+)+)]],
--   format = 'vscode://$1',
-- })

-- wezterm.on('open-uri', function(window, pane, uri)
-- 	local start, match_end = uri:find('vscode://');
-- 	if start == 1 then
-- 		local cwd = pane:get_current_working_dir()
-- 		local file_path = cwd .. uri:sub(match_end+1)

--     wezterm.log_info(cwd)

-- 		local url = 'vscode://' .. file_path .. '?windowId=_blank'

--     -- prevent the default action from opening in a browser
--     return url
-- 	end
-- end)

-- and finally, return the configuration to wezterm
return config