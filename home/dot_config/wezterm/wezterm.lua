local wezterm = require("wezterm")

local config = wezterm.config_builder()

local is_windows = os.getenv("OS") and os.getenv("OS"):lower():find("windows")
local is_macos = wezterm.target_triple:lower():find("darwin") ~= nil

-- Colors
config.color_scheme = "Catppuccin Mocha"

-- Font
config.font = wezterm.font("JetBrainsMonoNL Nerd Font", { weight = "Medium" })
config.font_size = 12.0
config.window_frame = {
	font = wezterm.font("JetBrainsMonoNL Nerd Font", { weight = "Bold" }),
}

-- Performance
config.max_fps = 120

-- Window
config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
config.window_padding = { left = 8, right = 8, top = 8, bottom = 8 }
config.inactive_pane_hsb = {
	saturation = 0.0,
	brightness = 0.5,
}

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

-- Platform-specific
if is_windows then
	config.win32_system_backdrop = "Acrylic"
	config.window_background_opacity = 0.7
	config.window_frame.font_size = 10.0
end

if is_macos then
	config.window_background_opacity = 0.8
	config.macos_window_background_blur = 50
	config.window_frame.font_size = 13.0
	config.window_padding = { left = 8, right = 8, top = 40, bottom = 8 }
end

return config
