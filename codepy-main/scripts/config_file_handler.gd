extends Node

## Configuration and Settings Manager - Handles persistent game settings
## Stores: language, volume, difficulty preferences, etc.

class_name ConfigFileHandler

const CONFIG_FILE = "user://mathblat_config.json"

var config_data: Dictionary = {
	"game": {},
	"audio": {},
	"graphics": {},
	"player": {}
}

func _ready() -> void:
	if not load_config():
		print("WARNING: ConfigFileHandler initialization failed, using defaults")
		_initialize_default_config()

## Load configuration from file
func load_config() -> bool:
	if not FileAccess.file_exists(CONFIG_FILE):
		_initialize_default_config()
		save_config()
		return true
	
	var file = FileAccess.open(CONFIG_FILE, FileAccess.READ)
	if file == null:
		print("WARNING: Failed to load config: ", FileAccess.get_open_error())
		_initialize_default_config()
		return false
	
	var json = JSON.new()
	var error = json.parse(file.get_as_text())
	if error == OK:
		config_data = json.data
		return true
	else:
		print("WARNING: Failed to parse config JSON, using defaults")
		_initialize_default_config()
		return false

## Initialize default configuration
func _initialize_default_config() -> void:
	config_data = {
		"game": {
			"language": "en",
			"last_difficulty": 0,
		},
		"audio": {
			"master_volume": 1.0,
			"music_volume": 1.0,
			"sfx_volume": 1.0,
			"enable_sound": true,
		},
		"graphics": {
			"particle_quality": 1.0,
			"screen_shake_enabled": true,
			"animations_enabled": true,
		},
		"player": {
			"total_wins": 0,
			"total_games": 0,
			"best_score": 0,
			"total_experience": 0,
			"player_level": 1,
		}
	}

## Save configuration to file
func save_config() -> bool:
	var json_string = JSON.stringify(config_data)
	var file = FileAccess.open(CONFIG_FILE, FileAccess.WRITE)
	if file == null:
		print("WARNING: Failed to save config: ", FileAccess.get_open_error())
		return false
	file.store_string(json_string)
	return true

## Load a specific setting
func load_setting(category: String, key: String, default_value = null):
	if category in config_data and key in config_data[category]:
		return config_data[category][key]
	return default_value

## Save a specific setting
func save_setting(category: String, key: String, value) -> bool:
	if not category in config_data:
		config_data[category] = {}
	config_data[category][key] = value
	return save_config()

## Get entire category
func get_category(category: String) -> Dictionary:
	return config_data.get(category, {})

## Reset configuration to defaults
func reset_to_defaults() -> void:
	_initialize_default_config()
	save_config()
