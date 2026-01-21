extends Node

## Feature Configuration - Manages optional features like teacher portal
## All features are configurable and can be disabled/enabled

# Feature toggles
var teacher_portal_enabled: bool = false
var energy_system_enabled: bool = true
var adventure_mode_enabled: bool = true
var multiplayer_enabled: bool = true

# Teacher settings (only relevant if teacher portal is enabled)
var teacher_mode: bool = false
var teacher_settings: Dictionary = {
	"class_code": "",
	"difficulty_restrictions": [],  # ["easy", "medium", "hard"]
	"time_limit_multiplier": 1.0,  # 1.0 = normal, 2.0 = double time
	"energy_cost_multiplier": 1.0,  # 1.0 = normal, 0.5 = half cost
	"max_players_per_class": 30,
	"class_name": "",
	"teacher_name": "",
	"session_active": false
}

# Energy system settings
var energy_settings: Dictionary = {
	"regen_rate": 10.0,  # Energy per minute
	"max_energy": 100,
	"single_player_cost": 15,
	"multiplayer_cost": 20
}

var config_file_path: String = "user://gameconfig.json"

func _ready() -> void:
	_load_configuration()

## Load configuration from file
func _load_configuration() -> void:
	if ResourceLoader.exists(config_file_path):
		var file = FileAccess.open(config_file_path, FileAccess.READ)
		if file:
			var json_string = file.get_as_text()
			var json = JSON.new()
			if json.parse(json_string) == OK:
				var data = json.get_data()
				teacher_portal_enabled = data.get("teacher_portal_enabled", false)
				energy_system_enabled = data.get("energy_system_enabled", true)
				adventure_mode_enabled = data.get("adventure_mode_enabled", true)
				multiplayer_enabled = data.get("multiplayer_enabled", true)
				teacher_settings = data.get("teacher_settings", teacher_settings)
				energy_settings = data.get("energy_settings", energy_settings)

## Save configuration to file
func _save_configuration() -> void:
	var config_data = {
		"teacher_portal_enabled": teacher_portal_enabled,
		"energy_system_enabled": energy_system_enabled,
		"adventure_mode_enabled": adventure_mode_enabled,
		"multiplayer_enabled": multiplayer_enabled,
		"teacher_settings": teacher_settings,
		"energy_settings": energy_settings
	}
	
	var json = JSON.stringify(config_data)
	var file = FileAccess.open(config_file_path, FileAccess.WRITE)
	if file:
		file.store_string(json)

## Enable or disable teacher portal
func set_teacher_portal_enabled(enabled: bool) -> void:
	teacher_portal_enabled = enabled
	_save_configuration()

## Enable or disable energy system
func set_energy_system_enabled(enabled: bool) -> void:
	energy_system_enabled = enabled
	_save_configuration()

## Enable or disable adventure mode
func set_adventure_mode_enabled(enabled: bool) -> void:
	adventure_mode_enabled = enabled
	_save_configuration()

## Enable or disable multiplayer
func set_multiplayer_enabled(enabled: bool) -> void:
	multiplayer_enabled = enabled
	_save_configuration()

## Set teacher mode active/inactive
func set_teacher_mode_active(active: bool) -> void:
	teacher_mode = active
	teacher_settings["session_active"] = active

## Update teacher settings
func update_teacher_settings(new_settings: Dictionary) -> void:
	teacher_settings.merge(new_settings)
	_save_configuration()

## Get a teacher setting value
func get_teacher_setting(setting_name: String, default_value = null):
	return teacher_settings.get(setting_name, default_value)

## Check if a difficulty is restricted by teacher
func is_difficulty_restricted(difficulty: String) -> bool:
	if not teacher_mode:
		return false
	var restrictions = teacher_settings.get("difficulty_restrictions", [])
	return difficulty.to_lower() in restrictions

## Get time limit multiplier from teacher settings
func get_time_limit_multiplier() -> float:
	if teacher_mode:
		return teacher_settings.get("time_limit_multiplier", 1.0)
	return 1.0

## Get energy cost multiplier from teacher settings
func get_energy_cost_multiplier() -> float:
	if teacher_mode:
		return teacher_settings.get("energy_cost_multiplier", 1.0)
	return 1.0

## Reset to default configuration
func reset_to_defaults() -> void:
	teacher_portal_enabled = false
	energy_system_enabled = true
	adventure_mode_enabled = true
	multiplayer_enabled = true
	teacher_mode = false
	teacher_settings = {
		"class_code": "",
		"difficulty_restrictions": [],
		"time_limit_multiplier": 1.0,
		"energy_cost_multiplier": 1.0,
		"max_players_per_class": 30,
		"class_name": "",
		"teacher_name": "",
		"session_active": false
	}
	_save_configuration()
