extends Control

## Main Menu with Audio Mute Toggle and Hard Mode Settings

@onready var audio_manager = get_node_or_null("/root/AudioManager")
@onready var mute_button = $VBoxContainer/TopPanel/MuteButton
@onready var hard_mode_toggle = $VBoxContainer/SettingsPanel/HardModeToggle
@onready var start_button = $VBoxContainer/CenterPanel/StartButton

var hard_mode_enabled: bool = false

func _ready() -> void:
	# Connect buttons
	if mute_button:
		mute_button.pressed.connect(_on_mute_pressed)
	if hard_mode_toggle:
		hard_mode_toggle.toggled.connect(_on_hard_mode_toggled)
	if start_button:
		start_button.pressed.connect(_on_start_game)
	
	# Load settings
	_load_settings()
	_update_mute_button()
	_update_hard_mode_display()

func _load_settings() -> void:
	if ConfigFileHandler:
		var settings = ConfigFileHandler.get_category("gameplay")
		hard_mode_enabled = settings.get("hard_mode", false)
		if hard_mode_toggle:
			hard_mode_toggle.button_pressed = hard_mode_enabled

func _on_mute_pressed() -> void:
	if audio_manager:
		audio_manager.toggle_mute()
		_update_mute_button()

func _update_mute_button() -> void:
	if not mute_button:
		return
	
	var is_muted = false
	if audio_manager:
		is_muted = audio_manager.is_muted()
	
	mute_button.text = "🔇 MUTED" if is_muted else "🔊 SOUND ON"
	mute_button.modulate = Color.GRAY if is_muted else Color.WHITE

func _on_hard_mode_toggled(enabled: bool) -> void:
	hard_mode_enabled = enabled
	if ConfigFileHandler:
		ConfigFileHandler.save_setting("gameplay", "hard_mode", enabled)
	
	if audio_manager:
		if enabled:
			audio_manager.play_sfx("unlock")
		else:
			audio_manager.play_sfx("click")
	
	_update_hard_mode_display()

func _update_hard_mode_display() -> void:
	if hard_mode_toggle:
		if hard_mode_enabled:
			hard_mode_toggle.text = "⚡ HARD MODE: ON (3x Timer Speed)"
			hard_mode_toggle.modulate = Color.RED
		else:
			hard_mode_toggle.text = "⚡ HARD MODE: OFF"
			hard_mode_toggle.modulate = Color.WHITE

func _on_start_game() -> void:
	if audio_manager:
		audio_manager.play_sfx("menu_select")
	
	# Pass hard mode to game manager
	if GameManager:
		GameManager.hard_mode = hard_mode_enabled
		GameManager.multiplier_multiplier = 1.0 if hard_mode_enabled else 1.5
		GameManager.time_multiplier = 3.0 if hard_mode_enabled else 1.0
	
	get_tree().change_scene_to_file("res://scenes/game_scene.tscn")
