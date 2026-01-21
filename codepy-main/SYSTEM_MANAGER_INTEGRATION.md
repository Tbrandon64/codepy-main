# System Manager Integration Guide

Quick reference for integrating fail-safe system calls in game code.

## Quick Integration

### Option 1: Automatic Safe Wrappers (Recommended)

Use `SystemManager` safe wrappers for all system calls:

```gdscript
# Instead of directly calling systems:
GameplayEnhancementSystem.on_correct_answer()

# Use safe wrapper:
SystemManager.safe_on_correct_answer()
```

### Option 2: Manual System Check

For advanced logic, check availability first:

```gdscript
if SystemManager.systems_available["AchievementSystem"]:
	SystemManager.safe_unlock_achievement("first_ten_correct")
else:
	print("Achievements not available")
```

---

## Common Integration Points

### Problem Generation

```gdscript
# Generate problem with fallback
var problem = SystemManager.safe_generate_problem()
display_problem(problem)
```

### Score Saving

```gdscript
# Save score with error handling
var saved = SystemManager.safe_save_score(player_name, score, difficulty)
if saved:
	print("Score saved!")
else:
	print("Score saved in memory only (not persisted)")
```

### Achievement Updates

```gdscript
# Unlock achievement with fallback
SystemManager.safe_unlock_achievement("first_correct")

# Update achievement progress
SystemManager.safe_update_achievement_progress("ten_correct", 1)
```

### Audio Playback

```gdscript
# Play sounds with graceful degradation
SystemManager.safe_play_correct_sound()  # Silent if audio unavailable
SystemManager.safe_play_wrong_sound()
```

### Localization

```gdscript
# Get translated text with fallback
var button_text = SystemManager.safe_get_text("BUTTON_OK", "OK")
button.text = button_text
```

### Bonus Point Calculation

```gdscript
# Calculate bonus points with fallback
var base_points = 10
var bonus = SystemManager.safe_calculate_bonus_points(base_points)
score += bonus
```

### Settings Management

```gdscript
# Load setting with default fallback
var volume = SystemManager.safe_load_setting("Audio", "MasterVolume", 1.0)

# Save setting with error handling
var saved = SystemManager.safe_save_setting("Audio", "MasterVolume", 0.8)
```

---

## Monitoring System Health

### Get Current Status

```gdscript
# Check if specific system is available
if SystemManager.systems_available["GameManager"]:
	print("Game system operational")

# Get all system status
var status = SystemManager.get_system_status()
for system_name in status.keys():
	print("%s: %s" % [system_name, "✅" if status[system_name] else "❌"])
```

### Detect Failures

```gdscript
# Check if any system failed
if SystemManager.are_any_systems_failed():
	var failed = SystemManager.get_failed_systems()
	print("Failed systems: ", failed)

# Check if critical systems available
if not SystemManager.are_critical_systems_available():
	print("WARNING: Critical systems unavailable!")
```

### Attempt Recovery

```gdscript
# Try to reinitialize a system
if SystemManager.reinitialize_system("AudioManager"):
	print("AudioManager reinitialized successfully")
else:
	print("Failed to reinitialize AudioManager")
```

---

## Scene Integration Examples

### In Game Scene

```gdscript
extends Node

func _ready() -> void:
	# Verify systems at game start
	if not SystemManager.are_critical_systems_available():
		print("WARNING: Running in degraded mode")
	
	start_game()

func start_game() -> void:
	var problem = SystemManager.safe_generate_problem()
	display_problem(problem)

func on_answer_selected(answer: int) -> void:
	var is_correct = GameManager.check_answer(answer)
	
	if is_correct:
		SystemManager.safe_on_correct_answer()
		SystemManager.safe_play_correct_sound()
	else:
		SystemManager.safe_play_wrong_sound()

func on_game_won() -> void:
	var saved = SystemManager.safe_save_score(
		player_name, 
		GameManager.score, 
        "MEDIUM"
	)
	show_victory_screen()
```

### In Main Menu

```gdscript
extends Node

func _ready() -> void:
	SystemManager.verify_all_systems()
	SystemManager.report_system_status()
	
	# Adjust UI based on available systems
	if not SystemManager.systems_available["LocalizationManager"]:
		print("Translation not available, using English")

func on_settings_pressed() -> void:
	# Load settings with fallback
	var master_volume = SystemManager.safe_load_setting(
		"Audio", 
		"MasterVolume", 
		1.0
	)
	
	show_settings_dialog(master_volume)

func on_volume_changed(new_volume: float) -> void:
	# Save settings
	SystemManager.safe_save_setting("Audio", "MasterVolume", new_volume)
```

### In Pause Menu

```gdscript
extends Node

func _ready() -> void:
	# Display current system status
	update_status_indicator()

func update_status_indicator() -> void:
	var status = SystemManager.get_system_status()
	var available = 0
	
	for system_available in status.values():
		if system_available:
			available += 1
	
	status_label.text = "Systems: %d/7 operational" % available
	
	if available < 5:
		status_label.add_theme_color_override("font_color", Color.YELLOW)
```

---

## Error Handling Patterns

### Try-Catch With Fallback

```gdscript
func safe_game_operation() -> void:
	try:
		# Attempt operation
		SystemManager.safe_on_correct_answer()
	except:
		print("Operation failed, using basic mode")
		# Fallback behavior
```

### Null Safety Check

```gdscript
func use_system(system_name: String) -> void:
	if SystemManager.systems_available.has(system_name):
		if SystemManager.systems_available[system_name]:
			# System is available
			pass
		else:
			print("System '%s' unavailable" % system_name)
	else:
		print("Unknown system '%s'" % system_name)
```

### Graceful Degradation

```gdscript
func update_ui() -> void:
	# Always show basics
	score_label.text = str(GameManager.score)
	
	# Only show extras if available
	if SystemManager.systems_available["GameplayEnhancementSystem"]:
		combo_label.visible = true
		streak_label.visible = true
	else:
		combo_label.visible = false
		streak_label.visible = false
```

---

## Testing System Behavior

### Test Disabled System

```gdscript
# Temporarily disable a system for testing
SystemManager.systems_available["AchievementSystem"] = false

# Call safe wrapper - should gracefully handle
SystemManager.safe_unlock_achievement("test")

# Re-enable
SystemManager.systems_available["AchievementSystem"] = true
```

### Test All Systems Available

```gdscript
# Query before and after
print("Before: %d systems available" % calculate_available())
print("Failed: ", SystemManager.get_failed_systems())

# Reinitialize
SystemManager.reinitialize_system("AudioManager")

print("After: %d systems available" % calculate_available())

func calculate_available() -> int:
	var count = 0
	for available in SystemManager.systems_available.values():
		if available:
			count += 1
	return count
```

---

## Configuration Through SystemManager

### Load All Settings

```gdscript
func load_game_settings() -> void:
	var difficulty = SystemManager.safe_load_setting(
		"Game", 
		"Difficulty", 
        "EASY"
	)
	
	var volume = SystemManager.safe_load_setting(
		"Audio", 
		"MasterVolume", 
		1.0
	)
	
	var language = SystemManager.safe_load_setting(
		"Localization", 
		"Language", 
        "EN"
	)
	
	apply_settings(difficulty, volume, language)
```

### Save All Settings

```gdscript
func save_game_settings() -> void:
	SystemManager.safe_save_setting("Game", "Difficulty", current_difficulty)
	SystemManager.safe_save_setting("Audio", "MasterVolume", master_volume)
	SystemManager.safe_save_setting("Localization", "Language", current_language)
```

---

## Best Practices

1. **Always use safe wrappers** - Never call systems directly in production code
2. **Check status at startup** - Call `SystemManager.report_system_status()` in debug
3. **Handle false returns** - Some operations return bool, check before proceeding
4. **Log warnings** - Watch console for WARNING messages indicating system failures
5. **Plan for degradation** - Assume enhancements may not be available
6. **Test failure modes** - Test with systems disabled to ensure graceful degradation

---

## Quick Reference Table

| Task | Function | Returns |
|------|----------|---------|
| Generate problem | `safe_generate_problem()` | MathProblem |
| Get translation | `safe_get_text(key)` | String |
| Play correct sound | `safe_play_correct_sound()` | void |
| Play wrong sound | `safe_play_wrong_sound()` | void |
| Unlock achievement | `safe_unlock_achievement(id)` | void |
| Update achievement | `safe_update_achievement_progress(id, amount)` | void |
| Calculate bonus | `safe_calculate_bonus_points(base)` | int |
| Save score | `safe_save_score(name, score, diff)` | bool |
| Load setting | `safe_load_setting(category, key, default)` | any |
| Save setting | `safe_save_setting(category, key, value)` | bool |
| Get status | `get_system_status()` | Dictionary |
| Get failures | `get_failed_systems()` | Array[String] |
| Verify all | `verify_all_systems()` | void |

---

For detailed fail-safe behavior, see [FAILSAFE_DOCUMENTATION.md](FAILSAFE_DOCUMENTATION.md)
