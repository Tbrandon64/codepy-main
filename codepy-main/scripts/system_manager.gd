extends Node

## System Manager - Handles initialization and fail-safes for all systems
## Detects missing/failed systems and provides fallback functionality

class_name SystemManager

# System availability flags
var systems_available: Dictionary = {
	"GameManager": false,
	"HighScoreManager": false,
	"AchievementSystem": false,
	"LocalizationManager": false,
	"ConfigFileHandler": false,
	"AudioManager": false,
	"GameplayEnhancementSystem": false
}

func _ready() -> void:
	verify_all_systems()
	report_system_status()

## Verify all systems are available and working
func verify_all_systems() -> void:
	print("=== System Status Check ===")
	
	# Check each system
	for system_name in systems_available.keys():
		if verify_system(system_name):
			systems_available[system_name] = true
			print("✅ %s: Available" % system_name)
		else:
			systems_available[system_name] = false
			print("⚠️  %s: Not available (using fallbacks)" % system_name)

## Verify a specific system is available
func verify_system(system_name: String) -> bool:
	match system_name:
		"GameManager":
			return is_instance_valid(GameManager) and GameManager.has_method("generate_problem")
		"HighScoreManager":
			return is_instance_valid(HighScoreManager) and HighScoreManager.has_method("save_score")
		"AchievementSystem":
			return is_instance_valid(AchievementSystem) and AchievementSystem.has_method("unlock_achievement")
		"LocalizationManager":
			return is_instance_valid(LocalizationManager) and LocalizationManager.has_method("get_text")
		"ConfigFileHandler":
			return is_instance_valid(ConfigFileHandler) and ConfigFileHandler.has_method("load_setting")
		"AudioManager":
			return is_instance_valid(AudioManager) and AudioManager.has_method("set_master_volume")
		"GameplayEnhancementSystem":
			return is_instance_valid(GameplayEnhancementSystem) and GameplayEnhancementSystem.has_method("on_correct_answer")
		_:
			return false

## Report system status
func report_system_status() -> void:
	var available_count = 0
	for system in systems_available.values():
		if system:
			available_count += 1
	
	print("=== System Summary ===")
	print("Available: %d/7" % available_count)
	
	if available_count == 7:
		print("✅ All systems operational - Full features enabled")
	elif available_count >= 5:
		print("⚠️  Most systems available - Limited features")
	elif available_count >= 3:
		print("⚠️  Core systems available - Basic gameplay only")
	else:
		print("❌ Critical systems unavailable - Fallback mode")
	
	print("============================")

## Safe wrapper for GameManager.generate_problem()
func safe_generate_problem():
	if systems_available["GameManager"]:
		try:
			return GameManager.generate_problem()
		except:
			print("ERROR: Failed to generate problem")
			return _fallback_problem()
	else:
		print("WARNING: GameManager unavailable, using fallback problem")
		return _fallback_problem()

## Fallback problem generation
func _fallback_problem():
	var problem = {
		"operand1": randi_range(1, 10),
		"operand2": randi_range(1, 10),
		"operation": ["+", "-", "*", "/"][randi() % 4],
		"options": [5, 10, 15, 20],
		"correct_answer": 10,
		"problem_text": "5 + 5 = ?"
	}
	return problem

## Safe wrapper for LocalizationManager.get_text()
func safe_get_text(key: String, default: String = "") -> String:
	if systems_available["LocalizationManager"]:
		try:
			return LocalizationManager.get_text(key, default)
		except:
			print("WARNING: Localization failed for key '%s'" % key)
			return default
	else:
		return default

## Safe wrapper for AudioManager.play_correct_sound()
func safe_play_correct_sound() -> void:
	if systems_available["AudioManager"]:
		try:
			AudioManager.play_correct_sound()
		except:
			print("WARNING: Failed to play correct sound")
			# Game continues without audio
	else:
		# Audio system not available, game continues without sound
		pass

## Safe wrapper for AudioManager.play_wrong_sound()
func safe_play_wrong_sound() -> void:
	if systems_available["AudioManager"]:
		try:
			AudioManager.play_wrong_sound()
		except:
			print("WARNING: Failed to play wrong sound")
			# Game continues without audio
	else:
		# Audio system not available, game continues without sound
		pass

## Safe wrapper for AchievementSystem.unlock_achievement()
func safe_unlock_achievement(achievement_id: String) -> void:
	if systems_available["AchievementSystem"]:
		try:
			AchievementSystem.unlock_achievement(achievement_id)
		except:
			print("WARNING: Failed to unlock achievement '%s'" % achievement_id)
	else:
		# Achievement system not available, game continues without achievements
		pass

## Safe wrapper for AchievementSystem.update_progress()
func safe_update_achievement_progress(achievement_id: String, amount: int = 1) -> void:
	if systems_available["AchievementSystem"]:
		try:
			AchievementSystem.update_progress(achievement_id, amount)
		except:
			print("WARNING: Failed to update achievement '%s'" % achievement_id)

## Safe wrapper for GameplayEnhancementSystem.on_correct_answer()
func safe_on_correct_answer() -> void:
	if systems_available["GameplayEnhancementSystem"]:
		try:
			GameplayEnhancementSystem.on_correct_answer()
		except:
			print("WARNING: Failed to update correct answer state")
	else:
		# Gameplay enhancements not available, basic gameplay continues
		pass

## Safe wrapper for GameplayEnhancementSystem.calculate_bonus_points()
func safe_calculate_bonus_points(base_points: int) -> int:
	if systems_available["GameplayEnhancementSystem"]:
		try:
			return GameplayEnhancementSystem.calculate_bonus_points(base_points)
		except:
			print("WARNING: Failed to calculate bonus points")
			return base_points
	else:
		# No multipliers, return base points
		return base_points

## Safe wrapper for HighScoreManager.save_score()
func safe_save_score(player_name: String, score: int, difficulty: String) -> bool:
	if systems_available["HighScoreManager"]:
		try:
			return HighScoreManager.save_score(player_name, score, difficulty)
		except:
			print("WARNING: Failed to save high score")
			return false
	else:
		# High score system not available
		print("WARNING: HighScoreManager unavailable, score not saved")
		return false

## Safe wrapper for ConfigFileHandler.load_setting()
func safe_load_setting(category: String, key: String, default = null):
	if systems_available["ConfigFileHandler"]:
		try:
			return ConfigFileHandler.load_setting(category, key, default)
		except:
			print("WARNING: Failed to load setting %s.%s" % [category, key])
			return default
	else:
		# Config system not available
		return default

## Safe wrapper for ConfigFileHandler.save_setting()
func safe_save_setting(category: String, key: String, value) -> bool:
	if systems_available["ConfigFileHandler"]:
		try:
			return ConfigFileHandler.save_setting(category, key, value)
		except:
			print("WARNING: Failed to save setting %s.%s" % [category, key])
			return false
	else:
		# Config system not available
		return false

## Check if all critical systems are available
func are_critical_systems_available() -> bool:
	return (systems_available["GameManager"] and 
			systems_available["HighScoreManager"])

## Check if any system failed
func are_any_systems_failed() -> bool:
	for system_status in systems_available.values():
		if not system_status:
			return true
	return false

## Get system status summary
func get_system_status() -> Dictionary:
	return systems_available.duplicate()

## Get list of failed systems
func get_failed_systems() -> Array[String]:
	var failed: Array[String] = []
	for system_name in systems_available.keys():
		if not systems_available[system_name]:
			failed.append(system_name)
	return failed

## Reinitialize a failed system
func reinitialize_system(system_name: String) -> bool:
	print("Attempting to reinitialize %s..." % system_name)
	
	match system_name:
		"GameManager":
			if GameManager:
				return verify_system("GameManager")
		"HighScoreManager":
			if HighScoreManager:
				return verify_system("HighScoreManager")
		"AchievementSystem":
			if AchievementSystem:
				return verify_system("AchievementSystem")
		"LocalizationManager":
			if LocalizationManager:
				return verify_system("LocalizationManager")
		"ConfigFileHandler":
			if ConfigFileHandler:
				return verify_system("ConfigFileHandler")
		"AudioManager":
			if AudioManager:
				return verify_system("AudioManager")
		"GameplayEnhancementSystem":
			if GameplayEnhancementSystem:
				return verify_system("GameplayEnhancementSystem")
	
	return false

signal system_failed(system_name: String)
signal all_systems_ready
signal critical_system_unavailable(system_name: String)
