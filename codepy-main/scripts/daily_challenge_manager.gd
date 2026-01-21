extends Node

## Daily Challenge System
## One unique challenge per day based on system date
## Loads problems from daily_challenges.json

class_name DailyChallengeManager

const CHALLENGES_PATH = "res://assets/daily_challenges.json"
var challenges: Array = []
var current_day_challenge: Dictionary = {}

func _ready() -> void:
	load_challenges()
	get_today_challenge()

func load_challenges() -> void:
	if ResourceLoader.exists(CHALLENGES_PATH):
		var file = FileAccess.open(CHALLENGES_PATH, FileAccess.READ)
		if file:
			var json = JSON.parse_string(file.get_as_text())
			if json and json is Array:
				challenges = json
	
	# Fallback challenges if file doesn't exist
	if challenges.is_empty():
		challenges = _generate_default_challenges()

func get_today_challenge() -> Dictionary:
	var today = Time.get_date_dict_from_system()
	var day_of_year = Time.get_ticks_msec() / (1000 * 60 * 60 * 24) % challenges.size()
	
	current_day_challenge = challenges[day_of_year] if day_of_year < challenges.size() else challenges[0]
	return current_day_challenge

func get_challenge_problems() -> Array:
	return current_day_challenge.get("problems", [])

func get_challenge_name() -> String:
	return current_day_challenge.get("name", "Daily Challenge")

func get_challenge_description() -> String:
	return current_day_challenge.get("description", "")

func is_challenge_completed() -> bool:
	var completed = current_day_challenge.get("completed", false)
	return completed

func mark_challenge_completed() -> void:
	current_day_challenge["completed"] = true
	# Save to local config
	if ConfigFileHandler:
		var today_str = Time.get_date_string_from_system()
		ConfigFileHandler.save_setting("daily_challenges", today_str, true)

func _generate_default_challenges() -> Array:
	# Pre-written 20 math problems as default challenges
	return [
		{
			"name": "Basic Arithmetic",
			"description": "Master the fundamentals",
			"problems": [
				{"a": 5, "b": 3, "op": "+"},
				{"a": 12, "b": 4, "op": "-"},
				{"a": 6, "b": 7, "op": "*"},
				{"a": 20, "b": 4, "op": "/"},
				{"a": 15, "b": 8, "op": "+"}
			]
		},
		{
			"name": "Multiplication Madness",
			"description": "Times tables attack",
			"problems": [
				{"a": 7, "b": 8, "op": "*"},
				{"a": 9, "b": 6, "op": "*"},
				{"a": 12, "b": 5, "op": "*"},
				{"a": 8, "b": 11, "op": "*"},
				{"a": 6, "b": 9, "op": "*"}
			]
		},
		{
			"name": "Division Master",
			"description": "Split it up",
			"problems": [
				{"a": 48, "b": 6, "op": "/"},
				{"a": 63, "b": 9, "op": "/"},
				{"a": 72, "b": 8, "op": "/"},
				{"a": 56, "b": 7, "op": "/"},
				{"a": 81, "b": 9, "op": "/"}
			]
		},
		{
			"name": "Mixed Ops",
			"description": "Can you handle all four?",
			"problems": [
				{"a": 25, "b": 5, "op": "/"},
				{"a": 18, "b": 9, "op": "+"},
				{"a": 7, "b": 6, "op": "*"},
				{"a": 30, "b": 12, "op": "-"},
				{"a": 4, "b": 8, "op": "+"}
			]
		},
		{
			"name": "Big Numbers",
			"description": "Think bigger",
			"problems": [
				{"a": 123, "b": 456, "op": "+"},
				{"a": 789, "b": 234, "op": "-"},
				{"a": 45, "b": 23, "op": "*"},
				{"a": 500, "b": 25, "op": "/"},
				{"a": 999, "b": 111, "op": "+"}
			]
		},
		{
			"name": "Lightning Round 1",
			"description": "Speed test",
			"problems": [
				{"a": 8, "b": 8, "op": "+"},
				{"a": 10, "b": 5, "op": "*"},
				{"a": 20, "b": 4, "op": "/"},
				{"a": 50, "b": 15, "op": "-"},
				{"a": 3, "b": 9, "op": "*"}
			]
		},
		{
			"name": "Tricky Tenths",
			"description": "Double-digit pairs",
			"problems": [
				{"a": 15, "b": 14, "op": "+"},
				{"a": 99, "b": 33, "op": "-"},
				{"a": 11, "b": 11, "op": "*"},
				{"a": 100, "b": 10, "op": "/"},
				{"a": 77, "b": 11, "op": "/"}
			]
		},
		{
			"name": "Combo Count",
			"description": "Keep the streak alive",
			"problems": [
				{"a": 2, "b": 2, "op": "+"},
				{"a": 4, "b": 4, "op": "*"},
				{"a": 16, "b": 4, "op": "/"},
				{"a": 12, "b": 8, "op": "-"},
				{"a": 9, "b": 3, "op": "/"}
			]
		},
		{
			"name": "Powers and Primes",
			"description": "Mathematical mastery",
			"problems": [
				{"a": 17, "b": 5, "op": "+"},
				{"a": 23, "b": 8, "op": "-"},
				{"a": 13, "b": 7, "op": "*"},
				{"a": 91, "b": 7, "op": "/"},
				{"a": 11, "b": 13, "op": "+"}
			]
		},
		{
			"name": "Recovery Day",
			"description": "Nice and easy",
			"problems": [
				{"a": 1, "b": 1, "op": "+"},
				{"a": 2, "b": 1, "op": "+"},
				{"a": 3, "b": 1, "op": "+"},
				{"a": 4, "b": 1, "op": "+"},
				{"a": 5, "b": 1, "op": "+"}
			]
		},
		{
			"name": "Challenge 11",
			"description": "Back to business",
			"problems": [
				{"a": 99, "b": 11, "op": "-"},
				{"a": 88, "b": 8, "op": "/"},
				{"a": 7, "b": 13, "op": "*"},
				{"a": 42, "b": 6, "op": "/"},
				{"a": 55, "b": 44, "op": "+"}
			]
		},
		{
			"name": "Challenge 12",
			"description": "Dozen problems",
			"problems": [
				{"a": 144, "b": 12, "op": "/"},
				{"a": 100, "b": 50, "op": "-"},
				{"a": 25, "b": 4, "op": "*"},
				{"a": 18, "b": 6, "op": "/"},
				{"a": 999, "b": 1, "op": "-"}
			]
		},
		{
			"name": "Challenge 13",
			"description": "Lucky thirteen",
			"problems": [
				{"a": 13, "b": 13, "op": "+"},
				{"a": 26, "b": 2, "op": "/"},
				{"a": 169, "b": 13, "op": "/"},
				{"a": 100, "b": 39, "op": "-"},
				{"a": 13, "b": 5, "op": "*"}
			]
		},
		{
			"name": "Challenge 14",
			"description": "Two weeks in",
			"problems": [
				{"a": 28, "b": 14, "op": "/"},
				{"a": 7, "b": 14, "op": "*"},
				{"a": 100, "b": 86, "op": "-"},
				{"a": 42, "b": 21, "op": "/"},
				{"a": 84, "b": 84, "op": "+"}
			]
		},
		{
			"name": "Challenge 15",
			"description": "Halfway mark",
			"problems": [
				{"a": 15, "b": 15, "op": "*"},
				{"a": 30, "b": 2, "op": "/"},
				{"a": 150, "b": 75, "op": "-"},
				{"a": 45, "b": 3, "op": "/"},
				{"a": 255, "b": 255, "op": "+"}
			]
		},
		{
			"name": "Challenge 16",
			"description": "Sweet sixteen",
			"problems": [
				{"a": 256, "b": 16, "op": "/"},
				{"a": 16, "b": 16, "op": "*"},
				{"a": 32, "b": 16, "op": "-"},
				{"a": 8, "b": 2, "op": "/"},
				{"a": 128, "b": 128, "op": "+"}
			]
		},
		{
			"name": "Challenge 17",
			"description": "Prime time",
			"problems": [
				{"a": 17, "b": 17, "op": "*"},
				{"a": 34, "b": 17, "op": "/"},
				{"a": 100, "b": 83, "op": "-"},
				{"a": 51, "b": 3, "op": "/"},
				{"a": 85, "b": 85, "op": "+"}
			]
		},
		{
			"name": "Challenge 18",
			"description": "Adulthood approaches",
			"problems": [
				{"a": 18, "b": 18, "op": "+"},
				{"a": 36, "b": 2, "op": "/"},
				{"a": 9, "b": 2, "op": "*"},
				{"a": 18, "b": 1, "op": "*"},
				{"a": 200, "b": 182, "op": "-"}
			]
		},
		{
			"name": "Challenge 19",
			"description": "Almost there",
			"problems": [
				{"a": 19, "b": 1, "op": "+"},
				{"a": 38, "b": 2, "op": "/"},
				{"a": 19, "b": 2, "op": "*"},
				{"a": 95, "b": 5, "op": "/"},
				{"a": 100, "b": 81, "op": "-"}
			]
		},
		{
			"name": "Challenge 20",
			"description": "Final countdown",
			"problems": [
				{"a": 20, "b": 20, "op": "*"},
				{"a": 400, "b": 20, "op": "/"},
				{"a": 500, "b": 480, "op": "-"},
				{"a": 100, "b": 80, "op": "-"},
				{"a": 10, "b": 10, "op": "+"}
			]
		}
	]
