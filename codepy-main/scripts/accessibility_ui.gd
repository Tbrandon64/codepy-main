extends Control

## Accessibility Settings UI
## Provides user interface for configuring all accessibility features

@onready var accessibility_manager: AccessibilityManager = AccessibilityManager.new()

# UI References
@onready var high_contrast_toggle = $VBoxContainer/HighContrastCheckBox
@onready var tts_toggle = $VBoxContainer/TTSCheckBox
@onready var font_size_slider = $VBoxContainer/FontSizeSlider
@onready var colorblind_dropdown = $VBoxContainer/ColorblindMode
@onready var motion_slider = $VBoxContainer/MotionSensitivity
@onready var screen_reader_toggle = $VBoxContainer/ScreenReaderCheckBox
@onready var captions_toggle = $VBoxContainer/CaptionsCheckBox
@onready var dyslexia_toggle = $VBoxContainer/DyslexiaFontCheckBox
@onready var reduce_animations_toggle = $VBoxContainer/ReduceAnimationsCheckBox
@onready var button_hints_toggle = $VBoxContainer/ButtonHintsCheckBox

func _ready() -> void:
	# Connect signals
	accessibility_manager.high_contrast_changed.connect(_on_high_contrast_changed)
	accessibility_manager.font_size_changed.connect(_on_font_size_changed)
	accessibility_manager.tts_enabled_changed.connect(_on_tts_changed)
	accessibility_manager.colorblind_mode_changed.connect(_on_colorblind_changed)
	accessibility_manager.motion_sensitivity_changed.connect(_on_motion_changed)
	accessibility_manager.screen_reader_changed.connect(_on_screen_reader_changed)
	accessibility_manager.captions_changed.connect(_on_captions_changed)
	accessibility_manager.button_hints_changed.connect(_on_button_hints_changed)
	
	# Connect UI signals
	if high_contrast_toggle:
		high_contrast_toggle.toggled.connect(_on_high_contrast_toggled)
	if tts_toggle:
		tts_toggle.toggled.connect(_on_tts_toggled)
	if font_size_slider:
		font_size_slider.value_changed.connect(_on_font_size_slider_changed)
	if colorblind_dropdown:
		colorblind_dropdown.item_selected.connect(_on_colorblind_selected)
	if motion_slider:
		motion_slider.value_changed.connect(_on_motion_slider_changed)
	if screen_reader_toggle:
		screen_reader_toggle.toggled.connect(_on_screen_reader_toggled)
	if captions_toggle:
		captions_toggle.toggled.connect(_on_captions_toggled)
	if dyslexia_toggle:
		dyslexia_toggle.toggled.connect(_on_dyslexia_toggled)
	if reduce_animations_toggle:
		reduce_animations_toggle.toggled.connect(_on_reduce_animations_toggled)
	if button_hints_toggle:
		button_hints_toggle.toggled.connect(_on_button_hints_toggled)
	
	# Initialize UI with current values
	_update_ui_values()

func _update_ui_values() -> void:
	if high_contrast_toggle:
		high_contrast_toggle.button_pressed = accessibility_manager.high_contrast_enabled
	if tts_toggle:
		tts_toggle.button_pressed = accessibility_manager.tts_enabled
	if font_size_slider:
		font_size_slider.value = accessibility_manager.font_size_multiplier
	if motion_slider:
		motion_slider.value = accessibility_manager.motion_sensitivity
	if screen_reader_toggle:
		screen_reader_toggle.button_pressed = accessibility_manager.screen_reader_enabled
	if captions_toggle:
		captions_toggle.button_pressed = accessibility_manager.captions_enabled
	if dyslexia_toggle:
		dyslexia_toggle.button_pressed = accessibility_manager.dyslexia_friendly_font
	if reduce_animations_toggle:
		reduce_animations_toggle.button_pressed = accessibility_manager.reduce_animations
	if button_hints_toggle:
		button_hints_toggle.button_pressed = accessibility_manager.show_button_hints

# Callbacks for UI changes
func _on_high_contrast_toggled(enabled: bool) -> void:
	accessibility_manager.set_high_contrast(enabled)

func _on_tts_toggled(enabled: bool) -> void:
	accessibility_manager.set_tts_enabled(enabled)

func _on_font_size_slider_changed(value: float) -> void:
	accessibility_manager.set_font_size_multiplier(value)

func _on_colorblind_selected(index: int) -> void:
	var modes = ["none", "deuteranopia", "protanopia", "tritanopia"]
	if index < modes.size():
		accessibility_manager.set_colorblind_mode(modes[index])

func _on_motion_slider_changed(value: float) -> void:
	accessibility_manager.set_motion_sensitivity(value)

func _on_screen_reader_toggled(enabled: bool) -> void:
	accessibility_manager.set_screen_reader_enabled(enabled)

func _on_captions_toggled(enabled: bool) -> void:
	accessibility_manager.set_captions_enabled(enabled)

func _on_dyslexia_toggled(enabled: bool) -> void:
	accessibility_manager.set_dyslexia_friendly_font(enabled)

func _on_reduce_animations_toggled(enabled: bool) -> void:
	accessibility_manager.set_reduce_animations(enabled)

func _on_button_hints_toggled(enabled: bool) -> void:
	accessibility_manager.set_show_button_hints(enabled)

# Callbacks for accessibility manager signals
func _on_high_contrast_changed(enabled: bool) -> void:
	if high_contrast_toggle:
		high_contrast_toggle.button_pressed = enabled

func _on_font_size_changed(multiplier: float) -> void:
	if font_size_slider:
		font_size_slider.value = multiplier

func _on_tts_changed(enabled: bool) -> void:
	if tts_toggle:
		tts_toggle.button_pressed = enabled

func _on_colorblind_changed(mode: String) -> void:
	if colorblind_dropdown:
		var modes = ["none", "deuteranopia", "protanopia", "tritanopia"]
		var index = modes.find(mode)
		if index >= 0:
			colorblind_dropdown.select(index)

func _on_motion_changed(value: float) -> void:
	if motion_slider:
		motion_slider.value = value

func _on_screen_reader_changed(enabled: bool) -> void:
	if screen_reader_toggle:
		screen_reader_toggle.button_pressed = enabled

func _on_captions_changed(enabled: bool) -> void:
	if captions_toggle:
		captions_toggle.button_pressed = enabled

func _on_button_hints_changed(enabled: bool) -> void:
	if button_hints_toggle:
		button_hints_toggle.button_pressed = enabled

# Presets for quick accessibility setup
func apply_preset(preset_name: String) -> void:
	match preset_name:
		"high_vision":
			accessibility_manager.set_high_contrast(true)
			accessibility_manager.set_font_size_multiplier(1.5)
			accessibility_manager.set_motion_sensitivity(0.5)
			accessibility_manager.set_show_button_hints(true)
		"screen_reader":
			accessibility_manager.set_screen_reader_enabled(true)
			accessibility_manager.set_tts_enabled(true)
			accessibility_manager.set_keyboard_navigation_enabled(true)
			accessibility_manager.set_show_button_hints(true)
		"motor_accessibility":
			accessibility_manager.set_motion_sensitivity(0.3)
			accessibility_manager.set_reduce_animations(true)
			accessibility_manager.set_keyboard_navigation_enabled(true)
		"dyslexia_friendly":
			accessibility_manager.set_dyslexia_friendly_font(true)
			accessibility_manager.set_font_size_multiplier(1.2)
			accessibility_manager.set_high_contrast(true)
		"colorblind":
			accessibility_manager.set_colorblind_mode("deuteranopia")
		_:
			pass
	
	_update_ui_values()

func reset_to_defaults() -> void:
	accessibility_manager.set_high_contrast(false)
	accessibility_manager.set_tts_enabled(false)
	accessibility_manager.set_font_size_multiplier(1.0)
	accessibility_manager.set_colorblind_mode("none")
	accessibility_manager.set_screen_reader_enabled(false)
	accessibility_manager.set_motion_sensitivity(1.0)
	accessibility_manager.set_show_button_hints(true)
	accessibility_manager.set_captions_enabled(false)
	accessibility_manager.set_dyslexia_friendly_font(false)
	accessibility_manager.set_reduce_animations(false)
	
	_update_ui_values()
