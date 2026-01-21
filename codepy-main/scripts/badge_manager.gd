extends Node

## Badge System - Track achievements and awards
## Saves to badges.json in user data directory

class_name BadgeManager

# Badge types
const BADGE_TYPES = {
	"first_win": {"name": "🚀 First Blast", "description": "Win your first game"},
	"ten_wins": {"name": "🌟 Ten Blasts", "description": "10 games won"},
	"high_combo": {"name": "⚡ Combo Master", "description": "100+ combo streak"},
	"speedrun": {"name": "⏱️ Speed Demon", "description": "Complete game in under 2 minutes"},
	"perfect_game": {"name": "💯 Perfect Math", "description": "No wrong answers in a game"},
	"marathon": {"name": "🏆 Marathon", "description": "Play for 1 hour straight"},
	"skill_up": {"name": "📈 Skill Climber", "description": "Increase difficulty and win"},
	"multiplayer_win": {"name": "👥 Social Butterfly", "description": "Win in multiplayer"},
	"hard_mode_master": {"name": "☠️ Hard Mode Hero", "description": "Complete hard mode"},
	"100_score": {"name": "💰 Centennial", "description": "Reach 100 points"}
}

var badges_earned: Dictionary = {}
var badge_save_path: String = "user://badges.json"

func _ready() -> void:
	load_badges()

func load_badges() -> void:
	if ResourceLoader.exists(badge_save_path):
		var file = FileAccess.open(badge_save_path, FileAccess.READ)
		if file:
			var json = JSON.parse_string(file.get_as_text())
			if json:
				badges_earned = json
	else:
		badges_earned = {}

func save_badges() -> void:
	var file = FileAccess.open(badge_save_path, FileAccess.WRITE)
	if file:
		var json_str = JSON.stringify(badges_earned)
		file.store_string(json_str)

func earn_badge(badge_id: String) -> bool:
	if badge_id not in BADGE_TYPES:
		return false
	
	if badge_id in badges_earned:
		return false  # Already earned
	
	badges_earned[badge_id] = {
		"earned_at": Time.get_ticks_msec(),
		"timestamp": Time.get_datetime_string_from_system()
	}
	
	save_badges()
	print("Badge earned: ", BADGE_TYPES[badge_id]["name"])
	return true

func has_badge(badge_id: String) -> bool:
	return badge_id in badges_earned

func get_badge_info(badge_id: String) -> Dictionary:
	if badge_id in BADGE_TYPES:
		return BADGE_TYPES[badge_id]
	return {}

func get_all_earned_badges() -> Array:
	var earned = []
	for badge_id in badges_earned.keys():
		earned.append({
			"id": badge_id,
			"info": BADGE_TYPES[badge_id],
			"earned_at": badges_earned[badge_id]["timestamp"]
		})
	return earned

func get_earned_count() -> int:
	return badges_earned.size()

func get_total_badges() -> int:
	return BADGE_TYPES.size()

# Check for badge conditions
func check_win(stats: Dictionary) -> void:
	# First win
	var wins = stats.get("total_wins", 0)
	if wins == 1:
		earn_badge("first_win")
	elif wins == 10:
		earn_badge("ten_wins")
	
	# Score 100
	if stats.get("score", 0) >= 100:
		earn_badge("100_score")
	
	# Speedrun (under 2 minutes)
	if stats.get("time_elapsed", 0) < 120:
		earn_badge("speedrun")
	
	# Perfect game (no wrong answers)
	if stats.get("wrong_answers", 0) == 0:
		earn_badge("perfect_game")
	
	# High combo
	if stats.get("max_combo", 0) >= 100:
		earn_badge("high_combo")

func check_multiplayer_win() -> void:
	earn_badge("multiplayer_win")

func check_hard_mode_win() -> void:
	earn_badge("hard_mode_master")

func check_marathon() -> void:
	earn_badge("marathon")

# Display badge in game
func display_badge_popup(badge_id: String) -> void:
	if badge_id not in BADGE_TYPES:
		return
	
	var badge_info = BADGE_TYPES[badge_id]
	print("🎖️ ", badge_info["name"])
	print("   ", badge_info["description"])
