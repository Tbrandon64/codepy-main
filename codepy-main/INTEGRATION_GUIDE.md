# MathBlat v2.0 - Developer Integration Guide

## Quick Start for Developers

### 1. Project Setup

#### Add Autoloads to project.godot
```ini
[autoload]
GameManager="*res://scripts/game_manager.gd"
HighScoreManager="*res://scripts/high_score_manager.gd"
AchievementSystem="*res://scripts/achievement_system.gd"
LocalizationManager="*res://scripts/localization_manager.gd"
ConfigFileHandler="*res://scripts/config_file_handler.gd"
AudioManager="*res://scripts/audio_manager.gd"
GameplayEnhancementSystem="*res://scripts/gameplay_enhancement_system.gd"
```

#### Create Audio Buses
In Godot Editor:
1. Open Audio panel → Buses tab
2. Create three buses: "Music", "SFX" (both under "Master")
3. Master bus will contain both

### 2. Game Scene Integration

#### Initialize in _ready():
```gdscript
extends CanvasLayer

var player_score: int = 0
var opponent_score: int = 0
var streak_count: int = 0

func _ready() -> void:
	# Initialize systems
	AudioManager.load_audio_settings()
	GameplayEnhancementSystem.reset_state()
	
	# Connect signals for feedback
	AchievementSystem.achievement_unlocked.connect(_on_achievement_unlocked)
	AchievementSystem.level_up.connect(_on_level_up)
	GameplayEnhancementSystem.combo_changed.connect(_on_combo_changed)
	GameplayEnhancementSystem.power_up_activated.connect(_on_power_up_activated)
	
	# Setup UI with localization
	_setup_localized_ui()
	
	# Start game
	_display_next_problem()
```

#### Setup Localized UI:
```gdscript
func _setup_localized_ui() -> void:
	$UI/TitleLabel.text = LocalizationManager.get_text("main_menu_title")
	$UI/ScoreBox/YourScoreLabel.text = LocalizationManager.get_text("your_score")
	$UI/ScoreBox/OpponentScoreLabel.text = LocalizationManager.get_text("opponent_score")
	$PauseMenu/PauseLabel.text = LocalizationManager.get_text("pause")
	# ... etc for all UI labels
```

### 3. Handle Correct Answer

#### Updated Answer Handler:
```gdscript
func _on_option_pressed(option_index: int) -> void:
	if is_waiting_for_result or connection_lost or is_paused:
		return
	
	is_waiting_for_result = true
	$GameTimer.stop()
	
	# Get selected answer
	var selected_answer = current_problem.options[option_index]
	var is_correct = selected_answer == current_problem.correct_answer
	
	if is_correct:
		# Handle correct answer with gameplay enhancements
		GameplayEnhancementSystem.on_correct_answer()
		streak_count = GameplayEnhancementSystem.get_streak()
		
		# Calculate points with combo multiplier
		var base_points = 10 * (GameManager.current_difficulty + 1)
		var bonus_points = GameplayEnhancementSystem.calculate_bonus_points(base_points)
		player_score += bonus_points
		
		# Display feedback
		var combo_mult = GameplayEnhancementSystem.get_combo_multiplier()
		if combo_mult > 1.0:
			var status_text = LocalizationManager.get_text_formatted("combo", [int(combo_mult)])
			$UI/VBoxContainer/StatusLabel.text = status_text
		else:
			$UI/VBoxContainer/StatusLabel.text = LocalizationManager.get_text_formatted("correct", [bonus_points])
		
		$UI/VBoxContainer/StatusLabel.add_theme_color_override("font_color", Color.GREEN)
		
		# Audio feedback
		AudioManager.play_correct_sound()
		_show_correct_particles()
		_animate_score_pop($UI/VBoxContainer/ScoreBox/YourScoreLabel)
		
	else:
		# Handle wrong answer - check shield power-up
		var was_protected = GameplayEnhancementSystem.on_wrong_answer()
		
		if was_protected:
			$UI/VBoxContainer/StatusLabel.text = LocalizationManager.get_text("shield_saved")
			$UI/VBoxContainer/StatusLabel.add_theme_color_override("font_color", Color.YELLOW)
		else:
			$UI/VBoxContainer/StatusLabel.text = LocalizationManager.get_text_formatted("wrong", [current_problem.correct_answer])
			$UI/VBoxContainer/StatusLabel.add_theme_color_override("font_color", Color.RED)
			streak_count = 0
		
		AudioManager.play_wrong_sound()
		_shake_screen()
	
	# Update display
	_update_scores()
	_disable_all_buttons()
	
	# Achievement updates
	if is_correct:
		AchievementSystem.update_progress("perfect_game", streak_count)
		AchievementSystem.update_progress("combo_master", GameplayEnhancementSystem.get_combo())
	else:
		if not was_protected:
			AchievementSystem.update_progress("shield", 0)  # Reset shield progress
	
	# Check for win condition
	if player_score >= win_score:
		_show_victory()
		AchievementSystem.unlock_achievement("first_win")
		AchievementSystem.update_progress("math_wizard", 1)
		return
	
	# Wait before next problem
	$ResultTimer.start()
```

### 4. Handle Language Changes

#### Add Language Settings Menu:
```gdscript
func _on_language_button_pressed(language_code: String) -> void:
	LocalizationManager.set_language(language_code)
	_setup_localized_ui()  # Refresh all UI text
```

#### Listen for Language Changes:
```gdscript
func _ready() -> void:
	LocalizationManager.language_changed.connect(_on_language_changed)

func _on_language_changed() -> void:
	_setup_localized_ui()  # Refresh when language changes
```

### 5. Audio Settings Integration

#### Add Volume Control UI:
```gdscript
func _on_master_volume_slider_changed(value: float) -> void:
	AudioManager.set_master_volume(value)

func _on_music_volume_slider_changed(value: float) -> void:
	AudioManager.set_music_volume(value)

func _on_sfx_volume_slider_changed(value: float) -> void:
	AudioManager.set_sfx_volume(value)

func _on_sound_toggle_pressed() -> void:
	var current_state = AudioManager.is_sound_enabled()
	AudioManager.set_sound_enabled(not current_state)
```

### 6. Achievement Notifications

#### Display Achievement Unlock:
```gdscript
func _on_achievement_unlocked(achievement_id: String, achievement_name: String) -> void:
	# Show achievement notification
	var notification = preload("res://scenes/achievement_notification.tscn").instantiate()
	add_child(notification)
	
	var text = LocalizationManager.get_text_formatted("achievement_unlocked", [achievement_name])
	notification.show_notification(text, achievement_id)
	
	# Play success sound
	AudioManager.play_correct_sound()

func _on_level_up(new_level: int) -> void:
	var player = AchievementSystem
	var exp_text = LocalizationManager.get_text_formatted("experience", [player.player_experience])
	$UI/LevelLabel.text = LocalizationManager.get_text_formatted("level", [new_level])
	print("Level up to %d! %s" % [new_level, exp_text])
```

### 7. Real-time Feedback

#### Combo Display:
```gdscript
func _on_combo_changed(combo_count: int, multiplier: float) -> void:
	if combo_count > 0:
		$UI/ComboLabel.text = LocalizationManager.get_text_formatted("combo", [int(multiplier)])
		$UI/ComboLabel.show()
		
		# Animate combo label
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_ELASTIC)
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_property($UI/ComboLabel, "scale", Vector2(1.2, 1.2), 0.3)
		tween.tween_property($UI/ComboLabel, "scale", Vector2.ONE, 0.2)
	else:
		$UI/ComboLabel.hide()

func _on_power_up_activated(power_up_id: String, power_up_name: String) -> void:
	var text = LocalizationManager.get_text_formatted("power_up_active", [power_up_name])
	$UI/PowerUpLabel.text = text
	$UI/PowerUpLabel.show()
	
	# Animate and auto-hide
	await get_tree().create_timer(2.0).timeout
	$UI/PowerUpLabel.hide()
```

### 8. Victory Screen Enhancement

#### Show Victory with Achievements:
```gdscript
func _show_victory() -> void:
	$GameTimer.stop()
	$ResultTimer.stop()
	
	# Save high score
	var difficulty_name = ["Easy", "Medium", "Hard"][GameManager.current_difficulty]
	HighScoreManager.save_score("Player", player_score, difficulty_name)
	
	# Update player stats
	ConfigFileHandler.save_setting("player", "best_score", 
									max(ConfigFileHandler.load_setting("player", "best_score", 0), player_score))
	ConfigFileHandler.save_setting("player", "total_wins",
									ConfigFileHandler.load_setting("player", "total_wins", 0) + 1)
	
	# Show victory screen with achievements
	var victory_scene = preload("res://scenes/victory_screen.tscn").instantiate()
	get_tree().root.add_child(victory_scene)
	
	# Pass data to victory screen
	victory_scene.setup_victory({
		"player_score": player_score,
		"opponent_score": opponent_score,
		"difficulty": difficulty_name,
		"achievements_unlocked": AchievementSystem.get_unlocked_count(),
		"player_level": AchievementSystem.player_level
	})
```

## Testing Checklist

### Unit Tests
- [ ] Problem generation creates 4 unique options
- [ ] Combo multiplier scales 1x → 5x correctly
- [ ] Streak resets on wrong answer
- [ ] Power-up removes after use
- [ ] Achievement unlocks when target reached
- [ ] Localization returns correct string for key
- [ ] Volume setting persists across sessions

### Integration Tests
- [ ] Game scene receives all signals
- [ ] Audio plays through correct bus
- [ ] Config saves to user directory
- [ ] Achievements display in victory screen
- [ ] Language change refreshes all UI
- [ ] High scores include multiplier bonus

### Performance Tests
- [ ] Problem generation < 2ms
- [ ] Language switch < 100ms
- [ ] 60 FPS maintained in gameplay
- [ ] No memory leaks over 30 minutes

## Debugging Tips

### Enable Debug Output
```gdscript
# In game_scene.gd
func _on_combo_changed(combo_count: int, multiplier: float) -> void:
	print("DEBUG: Combo %d, Multiplier %.1fx" % [combo_count, multiplier])
```

### Check Localization
```gdscript
# Test missing translations
print(LocalizationManager.get_text("nonexistent_key", "MISSING"))
```

### Monitor Audio
```gdscript
# Check volume levels
print("Master: %.1f, Music: %.1f, SFX: %.1f" % 
	  [AudioManager.master_volume, AudioManager.music_volume, AudioManager.sfx_volume])
```

### Verify Achievement Progress
```gdscript
# Check achievement state
var ach = AchievementSystem.get_achievement("combo_master")
print("Combo Master: %d/%d progress" % [ach["progress"], ach["target"]])
```

## Common Integration Patterns

### Pattern 1: Score Calculation with Bonuses
```gdscript
var base = 10 * (difficulty + 1)
var with_combo = int(base * GameplayEnhancementSystem.get_combo_multiplier())
var with_powerup = with_combo * (2 if "double_score" in GameplayEnhancementSystem.get_active_power_ups() else 1)
player_score += with_powerup
```

### Pattern 2: Dynamic UI Updates
```gdscript
# Update display based on game state
$UI/ScoreLabel.text = "%d" % player_score
$UI/ComboLabel.text = "x%.1f" % GameplayEnhancementSystem.get_combo_multiplier()
$UI/LevelLabel.text = "Lvl %d" % AchievementSystem.player_level
```

### Pattern 3: Localized Notifications
```gdscript
# Show localized feedback
var key = "correct" if is_correct else "wrong"
var message = LocalizationManager.get_text_formatted(key, [points])
$StatusLabel.text = message
```

## API Reference

### GameManager
```gdscript
generate_problem() -> MathProblem
check_answer(selected_answer: int) -> bool
set_difficulty(difficulty: Difficulty) -> void
reset() -> void
```

### GameplayEnhancementSystem
```gdscript
on_correct_answer() -> void
on_wrong_answer() -> bool  # Returns true if shielded
calculate_bonus_points(base: int) -> int
add_power_up(id: String) -> void
get_combo() -> int
get_combo_multiplier() -> float
```

### AchievementSystem
```gdscript
unlock_achievement(id: String) -> void
update_progress(id: String, amount: int) -> void
add_experience(amount: int) -> void
get_achievement(id: String) -> Dictionary
```

### LocalizationManager
```gdscript
get_text(key: String, default: String = "") -> String
get_text_formatted(key: String, args: Array = []) -> String
set_language(code: String) -> void
get_available_languages() -> Array[String]
```

### AudioManager
```gdscript
set_master_volume(volume: float) -> void
set_music_volume(volume: float) -> void
set_sfx_volume(volume: float) -> void
set_sound_enabled(enabled: bool) -> void
play_correct_sound() -> void
play_wrong_sound() -> void
```

### ConfigFileHandler
```gdscript
load_setting(category: String, key: String, default = null)
save_setting(category: String, key: String, value) -> bool
get_category(category: String) -> Dictionary
reset_to_defaults() -> void
```

---

**Last Updated**: 2026-01-20
**Version**: 2.0.0
**Status**: Complete
