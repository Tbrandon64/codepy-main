extends Node

const SCORES_FILE = "user://mathblat_highscores.json"
const MAX_HIGH_SCORES = 10

var high_scores: Array[Dictionary] = []

func _ready() -> void:
	if not load_high_scores():
		print("WARNING: HighScoreManager failed to initialize, using empty scores")
		high_scores = []

func save_score(player_name: String, score: int, difficulty: String) -> bool:
	"""Save a new high score entry with error handling"""
	var new_entry = {
		"name": player_name,
		"score": score,
		"difficulty": difficulty,
		"date": get_formatted_date()
	}
	
	high_scores.append(new_entry)
	high_scores.sort_custom(func(a, b): return a["score"] > b["score"])
	
	if high_scores.size() > MAX_HIGH_SCORES:
		high_scores.resize(MAX_HIGH_SCORES)
	
	if _write_scores_to_file():
		return true
	else:
		print("WARNING: Failed to save high score for '%s'" % player_name)
		return false

func load_high_scores() -> Array[Dictionary]:
	"""Load high scores from persistent storage with error handling"""
	if not FileAccess.file_exists(SCORES_FILE):
		high_scores = []
		return high_scores
	
	var file = FileAccess.open(SCORES_FILE, FileAccess.READ)
	if file == null:
		print("WARNING: Could not open scores file, using empty scores")
		return []
	
	var content = file.get_as_text()
	var json = JSON.new()
	var error = json.parse(content)
	
	if error != OK:
		print("WARNING: Failed to parse high scores JSON, using empty scores")
		return []
	
	var data = json.data
	if data is Array:
		high_scores = []
		for entry in data:
			if entry is Dictionary:
				high_scores.append(entry)
	
	return high_scores

func get_high_scores() -> Array[Dictionary]:
	"""Get sorted high scores"""
	return high_scores

func get_high_score_rank(score: int) -> int:
	"""Get rank position for a given score (1-indexed, returns rank + 1 if not in top 10)"""
	for i in range(high_scores.size()):
		if score > high_scores[i]["score"]:
			return i + 1
	return high_scores.size() + 1

func is_high_score(score: int) -> bool:
	"""Check if score qualifies for high scores list"""
	if high_scores.size() < MAX_HIGH_SCORES:
		return true
	return score > high_scores[-1]["score"]

func clear_high_scores() -> void:
	"""Clear all high scores (debug only)"""
	high_scores = []
	_write_scores_to_file()

func _write_scores_to_file() -> bool:
	"""Write high scores to persistent storage with error handling"""
	var json_string = JSON.stringify(high_scores)
	var file = FileAccess.open(SCORES_FILE, FileAccess.WRITE)
	
	if file == null:
		print("WARNING: Could not write scores file, scores not persisted")
		return false
	
	file.store_string(json_string)
	return true

func get_formatted_date() -> String:
	"""Get current date and time as formatted string"""
	var time = Time.get_ticks_msec()
	var dict = Time.get_datetime_dict_from_system()
	return "%04d-%02d-%02d %02d:%02d" % [dict.year, dict.month, dict.day, dict.hour, dict.minute]
