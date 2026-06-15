local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- Colors
config.color_scheme = "Catppuccin Mocha"

-- Font — matches iTerm setup
config.font = wezterm.font("JetBrainsMonoNL Nerd Font", { weight = "Medium" })
config.font_size = 12.0

-- Window
config.window_decorations = "RESIZE"
config.window_padding = { left = 8, right = 8, top = 8, bottom = 8 }

-- Tab bar
config.enable_tab_bar = true
config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true

-- Scrollback
config.scrollback_lines = 10000

-- Cursor
config.default_cursor_style = "BlinkingBlock"

-- Bell
config.audible_bell = "Disabled"

return config
