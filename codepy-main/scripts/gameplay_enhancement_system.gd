extends Node

## Gameplay Enhancement System - Adds power-ups, combos, and streaks
## Features: Combo multiplier, power-ups (2x Score, Freeze Time), streak tracking

class_name GameplayEnhancementSystem

var combo_count: int = 0
var streak_count: int = 0
var current_combo_multiplier: float = 1.0
var active_power_ups: Array[String] = []

# Power-up definitions
var power_ups: Dictionary = {
	"double_score": {
		"name": "2x Score",
		"description": "Double your points for next answer",
		"duration": 1,  # 1 correct answer
		"rarity": "common"
	},
	"freeze_time": {
		"name": "Freeze Time",
		"description": "Add 5 seconds to timer",
		"duration": 1,
		"rarity": "rare"
	},
	"shield": {
		"name": "Shield",
		"description": "Protect from one wrong answer",
		"duration": 1,
		"rarity": "rare"
	}
}

## Reset combo and streak at game start
func reset_state() -> void:
	combo_count = 0
	streak_count = 0
	current_combo_multiplier = 1.0
	active_power_ups.clear()

## Handle correct answer - increase combo and streak
func on_correct_answer() -> void:
	try:
		combo_count += 1
		streak_count += 1
		
		# Update combo multiplier (1x base, up to 5x at 25 combo)
		current_combo_multiplier = 1.0 + (float(combo_count) / 25.0) * 4.0
		current_combo_multiplier = min(current_combo_multiplier, 5.0)
		
		# Check for achievement updates (with fail-safe)
		if is_instance_valid(AchievementSystem):
			try:
				AchievementSystem.update_progress("combo_master", combo_count)
				AchievementSystem.update_progress("perfect_game", streak_count)
			except:
				print("WARNING: Failed to update achievements")
		
		combo_changed.emit(combo_count, current_combo_multiplier)
		streak_changed.emit(streak_count)
	except:
		print("WARNING: Failed to process correct answer")

## Handle wrong answer - reset combo, check for shield power-up
func on_wrong_answer() -> bool:
	# Check if shield power-up is active
	if "shield" in active_power_ups:
		remove_power_up("shield")
		return true  # Shield protected the player
	
	combo_count = 0
	current_combo_multiplier = 1.0
	combo_changed.emit(combo_count, current_combo_multiplier)
	return false

## Calculate bonus points based on current multipliers
func calculate_bonus_points(base_points: int) -> int:
	try:
		var bonus = base_points
		bonus = int(bonus * current_combo_multiplier)
		
		# Check for 2x score power-up
		if "double_score" in active_power_ups:
			bonus *= 2
			remove_power_up("double_score")
		
		return bonus
	except:
		print("WARNING: Failed to calculate bonus points, returning base")
		return base_points

## Add a power-up
func add_power_up(power_up_id: String) -> void:
	if power_up_id in power_ups:
		active_power_ups.append(power_up_id)
		power_up_activated.emit(power_up_id, power_ups[power_up_id]["name"])

## Remove a power-up
func remove_power_up(power_up_id: String) -> void:
	active_power_ups.erase(power_up_id)

## Get active power-ups list
func get_active_power_ups() -> Array[String]:
	return active_power_ups

## Get current combo count
func get_combo() -> int:
	return combo_count

## Get current streak count
func get_streak() -> int:
	return streak_count

## Get current combo multiplier
func get_combo_multiplier() -> float:
	return current_combo_multiplier

## Check if combo threshold reached for reward
func check_combo_milestone() -> bool:
	return combo_count > 0 and combo_count % 5 == 0

## Randomly grant a power-up (chance-based)
func grant_random_power_up() -> String:
	var power_up_list = power_ups.keys()
	var random_power_up = power_up_list[randi() % power_up_list.size()]
	add_power_up(random_power_up)
	return random_power_up

signal combo_changed(combo_count: int, multiplier: float)
signal streak_changed(streak_count: int)
signal power_up_activated(power_up_id: String, power_up_name: String)
