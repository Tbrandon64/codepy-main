extends Node

## Accessibility Manager - Comprehensive accessibility features
## Features: High Contrast, Text-to-Speech, Font Size, Colorblind Mode,
## Screen Reader, Keyboard Navigation, Motion Sensitivity, Captions

class_name AccessibilityManager

# Signals
signal high_contrast_changed(enabled: bool)
signal font_size_changed(size_multiplier: float)
signal tts_enabled_changed(enabled: bool)
signal colorblind_mode_changed(mode: String)
signal screen_reader_changed(enabled: bool)
signal keyboard_nav_changed(enabled: bool)
signal motion_sensitivity_changed(value: float)
signal captions_changed(enabled: bool)
signal button_hints_changed(enabled: bool)

# Accessibility Settings
var high_contrast_enabled: bool = false
var tts_enabled: bool = false
var font_size_multiplier: float = 1.0
var colorblind_mode: String = "none" # none, deuteranopia, protanopia, tritanopia
var screen_reader_enabled: bool = false
var keyboard_navigation_enabled: bool = true
var motion_sensitivity: float = 1.0 # 0.0-1.0
var show_button_hints: bool = true
var captions_enabled: bool = false
var dyslexia_friendly_font: bool = false
var reduce_animations: bool = false

# TTS Voice ID (OS dependent)
var tts_voice_id: String = ""

func _ready() -> void:
	# Initialize TTS voices if available
	_init_tts()
	
	# Load settings from ConfigFileHandler if available
	if is_instance_valid(ConfigFileHandler):
		load_settings()

func _init_tts() -> void:
	var voices = DisplayServer.tts_get_voices()
	if not voices.is_empty():
		# Default to the first available voice
		tts_voice_id = voices[0]["id"]
		# Try to find an English voice if possible
		for voice in voices:
			if "en" in voice.get("language", ""):
				tts_voice_id = voice["id"]
				break

func load_settings() -> void:
	var settings = ConfigFileHandler.get_category("accessibility")
	if settings.is_empty():
		# Default settings
		high_contrast_enabled = false
		tts_enabled = false
		font_size_multiplier = 1.0
		colorblind_mode = "none"
		screen_reader_enabled = false
		keyboard_navigation_enabled = true
		motion_sensitivity = 1.0
		show_button_hints = true
		captions_enabled = false
		dyslexia_friendly_font = false
		reduce_animations = false
	else:
		high_contrast_enabled = settings.get("high_contrast", false)
		tts_enabled = settings.get("tts_enabled", false)
		font_size_multiplier = settings.get("font_size_multiplier", 1.0)
		colorblind_mode = settings.get("colorblind_mode", "none")
		screen_reader_enabled = settings.get("screen_reader_enabled", false)
		keyboard_navigation_enabled = settings.get("keyboard_navigation_enabled", true)
		motion_sensitivity = settings.get("motion_sensitivity", 1.0)
		show_button_hints = settings.get("show_button_hints", true)
		captions_enabled = settings.get("captions_enabled", false)
		dyslexia_friendly_font = settings.get("dyslexia_friendly_font", false)
		reduce_animations = settings.get("reduce_animations", false)
	
	apply_settings()

func apply_settings() -> void:
	emit_signal("high_contrast_changed", high_contrast_enabled)
	emit_signal("font_size_changed", font_size_multiplier)
	emit_signal("tts_enabled_changed", tts_enabled)
	emit_signal("colorblind_mode_changed", colorblind_mode)
	emit_signal("screen_reader_changed", screen_reader_enabled)
	emit_signal("keyboard_nav_changed", keyboard_navigation_enabled)
	emit_signal("motion_sensitivity_changed", motion_sensitivity)
	emit_signal("captions_changed", captions_enabled)
	emit_signal("button_hints_changed", show_button_hints)

# High Contrast Mode
func set_high_contrast(enabled: bool) -> void:
	high_contrast_enabled = enabled
	if is_instance_valid(ConfigFileHandler):
		ConfigFileHandler.save_setting("accessibility", "high_contrast", enabled)
	emit_signal("high_contrast_changed", enabled)

func get_high_contrast_color(type: String) -> Color:
	if not high_contrast_enabled:
		return Color.WHITE
		
	match type:
		"background": return Color.BLACK
		"text": return Color.WHITE
		"button": return Color.BLACK
		"button_text": return Color.YELLOW
		"highlight": return Color.CYAN
		"error": return Color.MAGENTA
		"success": return Color.LIME
		"warning": return Color.YELLOW
		_: return Color.WHITE

# Text-to-Speech
func set_tts_enabled(enabled: bool) -> void:
	tts_enabled = enabled
	if is_instance_valid(ConfigFileHandler):
		ConfigFileHandler.save_setting("accessibility", "tts_enabled", enabled)
	emit_signal("tts_enabled_changed", enabled)
	
	if enabled:
		speak("Text to speech enabled")
	else:
		DisplayServer.tts_stop()

func speak(text: String, interrupt: bool = true) -> void:
	if not tts_enabled:
		return
		
	if interrupt:
		DisplayServer.tts_stop()
		
	if not tts_voice_id.is_empty():
		DisplayServer.tts_speak(text, tts_voice_id)
	else:
		print("TTS Warning: No voice available")

func stop_speaking() -> void:
	DisplayServer.tts_stop()

# Font Size
func set_font_size_multiplier(multiplier: float) -> void:
	font_size_multiplier = clamp(multiplier, 0.5, 2.5)
	if is_instance_valid(ConfigFileHandler):
		ConfigFileHandler.save_setting("accessibility", "font_size_multiplier", font_size_multiplier)
	emit_signal("font_size_changed", font_size_multiplier)

# Colorblind Mode Support
func set_colorblind_mode(mode: String) -> void:
	if mode in ["none", "deuteranopia", "protanopia", "tritanopia"]:
		colorblind_mode = mode
		if is_instance_valid(ConfigFileHandler):
			ConfigFileHandler.save_setting("accessibility", "colorblind_mode", mode)
		emit_signal("colorblind_mode_changed", mode)

func get_colorblind_adjusted_color(original_color: Color) -> Color:
	if colorblind_mode == "none":
		return original_color
	
	# Simplified color adjustment for different colorblind types
	match colorblind_mode:
		"deuteranopia": # Green-blind (most common)
			return Color(
				original_color.r * 0.625 + original_color.g * 0.375,
				original_color.r * 0.7 + original_color.g * 0.3,
				original_color.b
			)
		"protanopia": # Red-blind
			return Color(
				original_color.r * 0.567 + original_color.g * 0.433,
				original_color.r * 0.558 + original_color.g * 0.442,
				original_color.b
			)
		"tritanopia": # Blue-yellow blind
			return Color(
				original_color.r,
				original_color.g * 0.95 + original_color.b * 0.05,
				original_color.g * 0.433 + original_color.b * 0.567
			)
		_:
			return original_color

# Screen Reader Support
func set_screen_reader_enabled(enabled: bool) -> void:
	screen_reader_enabled = enabled
	if is_instance_valid(ConfigFileHandler):
		ConfigFileHandler.save_setting("accessibility", "screen_reader_enabled", enabled)
	emit_signal("screen_reader_changed", enabled)
	
	if enabled:
		speak("Screen reader enabled. Use keyboard to navigate.", true)

# Keyboard Navigation
func set_keyboard_navigation_enabled(enabled: bool) -> void:
	keyboard_navigation_enabled = enabled
	if is_instance_valid(ConfigFileHandler):
		ConfigFileHandler.save_setting("accessibility", "keyboard_navigation_enabled", enabled)
	emit_signal("keyboard_nav_changed", enabled)

# Motion Sensitivity
func set_motion_sensitivity(sensitivity: float) -> void:
	motion_sensitivity = clamp(sensitivity, 0.0, 1.0)
	if is_instance_valid(ConfigFileHandler):
		ConfigFileHandler.save_setting("accessibility", "motion_sensitivity", motion_sensitivity)
	emit_signal("motion_sensitivity_changed", motion_sensitivity)

func should_reduce_motion() -> bool:
	return motion_sensitivity < 0.5 or reduce_animations

# Button Hints
func set_show_button_hints(enabled: bool) -> void:
	show_button_hints = enabled
	if is_instance_valid(ConfigFileHandler):
		ConfigFileHandler.save_setting("accessibility", "show_button_hints", enabled)
	emit_signal("button_hints_changed", enabled)

# Captions
func set_captions_enabled(enabled: bool) -> void:
	captions_enabled = enabled
	if is_instance_valid(ConfigFileHandler):
		ConfigFileHandler.save_setting("accessibility", "captions_enabled", enabled)
	emit_signal("captions_changed", enabled)

# Dyslexia-Friendly Font
func set_dyslexia_friendly_font(enabled: bool) -> void:
	dyslexia_friendly_font = enabled
	if is_instance_valid(ConfigFileHandler):
		ConfigFileHandler.save_setting("accessibility", "dyslexia_friendly_font", enabled)

func get_font_name() -> String:
	if dyslexia_friendly_font:
		return "res://assets/fonts/OpenDyslexic.ttf"
	return "res://assets/fonts/default.ttf"

# Animation Reduction
func set_reduce_animations(enabled: bool) -> void:
	reduce_animations = enabled
	if is_instance_valid(ConfigFileHandler):
		ConfigFileHandler.save_setting("accessibility", "reduce_animations", enabled)

# Screen Reader Announcements
func announce(text: String, priority: bool = true) -> void:
	if screen_reader_enabled or tts_enabled:
		speak(text, priority)

# Get scaled animation duration based on motion sensitivity
func get_animation_duration(default_duration: float) -> float:
	if reduce_animations:
		return default_duration * 0.3
	return default_duration * motion_sensitivity

# Helper to check if any accessibility features are enabled
func has_accessibility_features() -> bool:
	return high_contrast_enabled or tts_enabled or font_size_multiplier != 1.0 or \
		   colorblind_mode != "none" or screen_reader_enabled or show_button_hints or \
		   captions_enabled or dyslexia_friendly_font or reduce_animations
