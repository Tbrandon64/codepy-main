extends Node

## Achievement and Engagement System - Tracks player progress and unlocks
## Achievements: First Win, Perfect Game, Speed Demon, Combo Master, etc.

const ACHIEVEMENTS_FILE = "user://math_blast_achievements.json"

var achievements: Dictionary = {}
var player_level: int = 1
var player_experience: int = 0
var experience_to_next_level: int = 100

func _ready() -> void:
	if true:  # Always attempt initialization
		_initialize_achievements()
		load_achievements()

## Initialize achievement definitions
func _initialize_achievements() -> void:
	achievements = {
		"first_win": {
			"name": "First Win",
			"description": "Win your first game",
			"unlocked": false,
			"points": 10,
			"progress": 0,
			"target": 1
		},
		"perfect_game": {
			"name": "Perfect Game",
			"description": "Answer 10 questions in a row correctly",
			"unlocked": false,
			"points": 50,
			"progress": 0,
			"target": 10
		},
		"speed_demon": {
			"name": "Speed Demon",
			"description": "Answer a question in under 2 seconds",
			"unlocked": false,
			"points": 25,
			"progress": 0,
			"target": 1
		},
		"combo_master": {
			"name": "Combo Master",
			"description": "Reach a 25x combo multiplier",
			"unlocked": false,
			"points": 75,
			"progress": 0,
			"target": 25
		},
		"math_wizard": {
			"name": "Math Wizard",
			"description": "Win 10 games",
			"unlocked": false,
			"points": 100,
			"progress": 0,
			"target": 10
		},
		"hard_mode_master": {
			"name": "Hard Mode Master",
			"description": "Win 5 games on Hard difficulty",
			"unlocked": false,
			"points": 150,
			"progress": 0,
			"target": 5
		},
		"speed_racer": {
			"name": "Speed Racer",
			"description": "Win a game in under 2 minutes",
			"unlocked": false,
			"points": 40,
			"progress": 0,
			"target": 1
		}
	}

## Unlock an achievement
func unlock_achievement(achievement_id: String) -> void:
	if achievement_id in achievements and not achievements[achievement_id]["unlocked"]:
		achievements[achievement_id]["unlocked"] = true
		var exp_gain = achievements[achievement_id]["points"]
		add_experience(exp_gain)
		achievement_unlocked.emit(achievement_id, achievements[achievement_id]["name"])
		var saved = save_achievements()
		if not saved:
			print("WARNING: Failed to save achievements for '%s'" % achievement_id)
	else:
		if not (achievement_id in achievements):
			print("WARNING: Achievement '%s' not found" % achievement_id)

## Update achievement progress
func update_progress(achievement_id: String, amount: int = 1) -> void:
	if achievement_id in achievements:
		var ach = achievements[achievement_id]
		if not ach["unlocked"]:
			ach["progress"] = min(ach["progress"] + amount, ach["target"])
			if ach["progress"] >= ach["target"]:
				unlock_achievement(achievement_id)

## Add experience and handle leveling
func add_experience(amount: int) -> void:
	if amount > 0:
		player_experience += amount
		while player_experience >= experience_to_next_level:
			player_experience -= experience_to_next_level
			player_level += 1
			experience_to_next_level = int(100 * pow(1.1, player_level))
			level_up.emit(player_level)
		var saved = save_achievements()
		if not saved:
			print("WARNING: Failed to save achievements after experience gain")
	else:
		print("WARNING: Invalid experience amount: %d" % amount)

## Get achievement info
func get_achievement(achievement_id: String) -> Dictionary:
	return achievements.get(achievement_id, {})

## Get all achievements
func get_all_achievements() -> Dictionary:
	return achievements

## Get unlocked achievement count
func get_unlocked_count() -> int:
	var count = 0
	for achievement in achievements.values():
		if achievement["unlocked"]:
			count += 1
	return count

## Check if achievement is unlocked
func is_achievement_unlocked(achievement_id: String) -> bool:
	return achievements.get(achievement_id, {}).get("unlocked", false)

## Get progress percentage for an achievement
func get_progress_percentage(achievement_id: String) -> float:
	var ach = achievements.get(achievement_id, {})
	if ach.is_empty() or ach["target"] == 0:
		return 0.0
	return float(ach["progress"]) / float(ach["target"]) * 100.0

## Save achievements to file
func save_achievements() -> bool:
	var save_data = {
		"achievements": achievements,
		"player_level": player_level,
		"player_experience": player_experience
	}
	var json_string = JSON.stringify(save_data)
	var file = FileAccess.open(ACHIEVEMENTS_FILE, FileAccess.WRITE)
	if file == null:
		print("WARNING: Failed to open achievements file: ", FileAccess.get_open_error())
		return false
	if json_string.is_empty():
		print("WARNING: Failed to stringify achievements data")
		return false
	file.store_string(json_string)
	return true

## Load achievements from file
func load_achievements() -> void:
	if not FileAccess.file_exists(ACHIEVEMENTS_FILE):
		var saved = save_achievements()
		if not saved:
			print("WARNING: Failed to create achievements file")
		return
	
	var file = FileAccess.open(ACHIEVEMENTS_FILE, FileAccess.READ)
	if file == null:
		print("WARNING: Failed to load achievements: ", FileAccess.get_open_error())
		return
	
	var file_content = file.get_as_text()
	if file_content.is_empty():
		print("WARNING: Achievements file is empty")
		return
	
	var json = JSON.new()
	var error = json.parse(file_content)
	if error != OK:
		print("WARNING: Failed to parse achievements JSON")
		return
	
	var data = json.data
	if data and data is Dictionary:
		if "achievements" in data:
			achievements = data["achievements"]
		if "player_level" in data:
			player_level = data["player_level"]
		if "player_experience" in data:
			player_experience = data["player_experience"]
	else:
		print("WARNING: Achievements data is not a valid Dictionary")

signal achievement_unlocked(achievement_id: String, achievement_name: String)
signal level_up(new_level: int)
