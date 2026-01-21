extends Node

## Player Profile System
## Manages player names, stats, and profiles
## Saves to player_profiles.json

class_name PlayerProfileManager

const PROFILES_PATH = "user://player_profiles.json"

var current_profile: Dictionary = {}
var profiles: Dictionary = {}

func _ready() -> void:
	load_profiles()
	if profiles.is_empty():
		create_new_profile("Player One")

func load_profiles() -> void:
	if ResourceLoader.exists(PROFILES_PATH):
		var file = FileAccess.open(PROFILES_PATH, FileAccess.READ)
		if file:
			var json = JSON.parse_string(file.get_as_text())
			if json and json is Dictionary:
				profiles = json
	
	if profiles.is_empty():
		profiles = {}

func save_profiles() -> void:
	var file = FileAccess.open(PROFILES_PATH, FileAccess.WRITE)
	if file:
		var json_str = JSON.stringify(profiles)
		file.store_string(json_str)

func create_new_profile(player_name: String) -> Dictionary:
	var profile_id = str(Time.get_ticks_msec())
	var profile = {
		"id": profile_id,
		"name": player_name,
		"created_at": Time.get_datetime_string_from_system(),
		"last_played": Time.get_datetime_string_from_system(),
		"total_wins": 0,
		"total_games": 0,
		"high_score": 0,
		"total_playtime": 0,
		"badges": [],
		"achievements": {}
	}
	
	profiles[profile_id] = profile
	current_profile = profile
	save_profiles()
	return profile

func set_current_profile(profile_id: String) -> bool:
	if profile_id in profiles:
		current_profile = profiles[profile_id]
		return true
	return false

func rename_profile(profile_id: String, new_name: String) -> bool:
	if profile_id in profiles:
		profiles[profile_id]["name"] = new_name
		if current_profile.get("id") == profile_id:
			current_profile["name"] = new_name
		save_profiles()
		return true
	return false

func get_current_profile_name() -> String:
	return current_profile.get("name", "Player One")

func update_profile_stats(stats: Dictionary) -> void:
	if current_profile.is_empty():
		return
	
	var profile_id = current_profile.get("id", "")
	if profile_id in profiles:
		var profile = profiles[profile_id]
		profile["total_games"] += 1
		profile["last_played"] = Time.get_datetime_string_from_system()
		
		if stats.get("won", false):
			profile["total_wins"] += 1
		
		profile["high_score"] = max(profile.get("high_score", 0), stats.get("score", 0))
		profile["total_playtime"] += stats.get("playtime", 0)
		
		save_profiles()

func get_profile_stats() -> Dictionary:
	if current_profile.is_empty():
		return {}
	
	return {
		"name": current_profile.get("name", ""),
		"wins": current_profile.get("total_wins", 0),
		"games": current_profile.get("total_games", 0),
		"high_score": current_profile.get("high_score", 0),
		"playtime": current_profile.get("total_playtime", 0),
		"win_rate": _calculate_win_rate()
	}

func _calculate_win_rate() -> float:
	var total_games = current_profile.get("total_games", 0)
	if total_games == 0:
		return 0.0
	
	var wins = current_profile.get("total_wins", 0)
	return float(wins) / float(total_games)

func get_all_profiles() -> Array:
	var profile_list = []
	for profile_id in profiles.keys():
		profile_list.append(profiles[profile_id])
	return profile_list

func delete_profile(profile_id: String) -> bool:
	if profile_id in profiles:
		profiles.erase(profile_id)
		if current_profile.get("id") == profile_id:
			current_profile = {}
		save_profiles()
		return true
	return false

func export_profile_data(profile_id: String) -> String:
	if profile_id in profiles:
		return JSON.stringify(profiles[profile_id])
	return ""
