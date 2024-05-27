local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.front_end = "WebGpu"
config.enable_wayland = true
config.webgpu_power_preference = "HighPerformance"
config.animation_fps = 1
config.cursor_blink_ease_in = "Constant"
config.cursor_blink_ease_out = "Constant"

config.color_scheme = "Catppuccin Frappe"
config.font = wezterm.font_with_fallback({
	"Maple Mono",
	"Nerd Font Symbols",
})
config.font_size = 13
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = true

return config
