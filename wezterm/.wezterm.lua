-- Pull in the wezterm API
local wezterm = require 'wezterm'
local act = wezterm.action

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

config.color_scheme = 'concrete'

-- Disable all keybindings since window management should be done via zellij
config.disable_default_key_bindings = true

config.keys = {
  -- Reenable copy & pasting
  { key = 'v', mods = 'SUPER', action = wezterm.action.PasteFrom 'Clipboard' },
  { key = 'V', mods = 'CTRL', action = wezterm.action.PasteFrom 'Clipboard' },
  { key = 'V', mods = 'SHIFT|CTRL', action = wezterm.action.PasteFrom 'Clipboard' },
  { key = 'Paste', mods = 'NONE', action = wezterm.action.PasteFrom 'Clipboard' },
  { key = 'Copy', mods = 'NONE', action = wezterm.action.CopyTo 'Clipboard' },
  { key = 'c', mods = 'SUPER', action = wezterm.action.CopyTo 'Clipboard' },
  { key = 'C', mods = 'CTRL', action = wezterm.action.CopyTo 'Clipboard' },
  { key = 'C', mods = 'SHIFT|CTRL', action = wezterm.action.CopyTo 'Clipboard' },

  -- Font size adjustments
  { key = '_', mods = 'CTRL', action = wezterm.action.DecreaseFontSize },
  { key = '_', mods = 'SHIFT|CTRL', action = wezterm.action.DecreaseFontSize },
  { key = '=', mods = 'CTRL', action = wezterm.action.IncreaseFontSize },
  { key = '=', mods = 'SHIFT|CTRL', action = wezterm.action.IncreaseFontSize },
  { key = '=', mods = 'SUPER', action = wezterm.action.IncreaseFontSize },
  { key = '+', mods = 'CTRL', action = wezterm.action.IncreaseFontSize },
  { key = '+', mods = 'SHIFT|CTRL', action = wezterm.action.IncreaseFontSize },
  { key = '-', mods = 'CTRL', action = wezterm.action.DecreaseFontSize },
  { key = '-', mods = 'SHIFT|CTRL', action = wezterm.action.DecreaseFontSize },
  { key = '-', mods = 'SUPER', action = wezterm.action.DecreaseFontSize },

  -- Quit the application
  { key = 'q', mods = 'SHIFT|CTRL', action = wezterm.action.QuitApplication },
  { key = 'q', mods = 'SUPER', action = wezterm.action.QuitApplication },

   -- Make Option-Left equivalent to Alt-b which many line editors interpret as backward-word
  { key="LeftArrow", mods="OPT", action=wezterm.action{SendString="\x1bb"} },
  
  -- Make Option-Right equivalent to Alt-f; forward-word
  { key="RightArrow", mods="OPT", action=wezterm.action{SendString="\x1bf"} },
}

-- Update open uri function to open vscode:// links
wezterm.on("open-uri", function(window, pane, uri)
  -- TODO: Use https://wezfurlong.org/wezterm/config/lua/wezterm.procinfo/current_working_dir_for_pid.html instead
  local success, stdout, stderr = wezterm.run_child_process { 'sh', '-c', 'lsof -a -p $$ -d cwd -Fn | sed -n \'3p\' | sed \'s/^n//\'' }

  -- Logs can be found at: $HOME/.local/share/wezterm
  print(stdout)

  return true

	-- local start, match_end = uri:find("vscode://")
	-- if start == 1 then
	-- 	local cwd = pane:get_current_working_dir()
	-- 	local file_path = cwd .. uri:sub(match_end + 1)
	-- 	local url = "vscode://file" .. file_path
	-- 	window.open_with(url)
	-- 	return false
	-- end
end)

-- Use the defaults as a base
config.hyperlink_rules = wezterm.default_hyperlink_rules()

table.insert(config.hyperlink_rules, {
  regex = "[/.A-Za-z0-9_-]+\\.[A-Za-z0-9]+(:\\d+)*(?=\\s*|$)",
  format = "https://vscode://$0"
})

-- and finally, return the configuration to wezterm
return config
