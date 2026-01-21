extends Control

## Adventure Level - The actual gameplay scene for an adventure dungeon
## Similar to single_player.gd but integrated with adventure progression

@onready var problem_label = $VBoxContainer/ProblemLabel
@onready var timer_label = $VBoxContainer/TimerLabel
@onready var score_label = $VBoxContainer/ScoreLabel
@onready var level_label = $VBoxContainer/LevelLabel
@onready var energy_label = $VBoxContainer/EnergyLabel
@onready var buttons_container = $VBoxContainer/ButtonsContainer

# Game state
var current_problem: Dictionary = {}
var current_score: int = 0
var time_remaining: float = 15.0
var game_running: bool = true
var current_dungeon_id: int = -1
var dungeon_difficulty: String = "easy"
var level_count: int = 0

# Game timer
var game_timer: float = 0.0
var total_game_time: float = 0.0

# UI buttons
var answer_buttons: Array[Button] = []

func _ready() -> void:
	# Get the current dungeon info
	var dungeons = AdventureManager.get_current_map_dungeons()
	if dungeons.size() > 0:
		# Find first non-cleared dungeon
		for dungeon in dungeons:
			if not dungeon.cleared:
				current_dungeon_id = dungeon.id
				dungeon_difficulty = dungeon.difficulty
				break
	
	# Set GameManager difficulty
	_set_difficulty_from_string(dungeon_difficulty)
	
	# Setup UI
	_setup_ui()
	
	# Generate first problem
	_generate_new_problem()
	
	# Connect signals
	if FeatureConfig.energy_system_enabled:
		EnergySystem.energy_changed.connect(_on_energy_changed)

## Setup the UI elements
func _setup_ui() -> void:
	level_label.text = "Dungeon Level: %d" % (current_dungeon_id + 1)
	
	# Create answer buttons
	for i in range(4):
		var button = Button.new()
		button.custom_minimum_size = Vector2(150, 50)
		button.pressed.connect(func(): _on_answer_selected(i))
		buttons_container.add_child(button)
		answer_buttons.append(button)
	
	# Update energy display if enabled
	if FeatureConfig.energy_system_enabled:
		energy_label.text = "Energy: %d/%d" % [EnergySystem.get_current_energy(), EnergySystem.get_max_energy()]
		energy_label.show()

## Set difficulty from string
func _set_difficulty_from_string(difficulty: String) -> void:
	match difficulty.to_lower():
		"easy":
			GameManager.current_difficulty = GameManager.Difficulty.EASY
		"medium":
			GameManager.current_difficulty = GameManager.Difficulty.MEDIUM
		"hard":
			GameManager.current_difficulty = GameManager.Difficulty.HARD

## Generate a new math problem
func _generate_new_problem() -> void:
	var problem = GameManager.generate_problem()
	current_problem = GameManager.current_problem
	
	# Display problem
	problem_label.text = current_problem["problem_text"]
	
	# Display answer options
	var options = current_problem["options"]
	for i in range(4):
		if i < options.size():
			answer_buttons[i].text = str(options[i])
			answer_buttons[i].disabled = false
		else:
			answer_buttons[i].text = ""
			answer_buttons[i].disabled = true
	
	# Reset timer
	time_remaining = FeatureConfig.get_time_limit_multiplier() * 15.0
	game_timer = 0.0

func _process(delta: float) -> void:
	if not game_running:
		return
	
	game_timer += delta
	total_game_time += delta
	time_remaining -= delta
	
	# Update timer display
	timer_label.text = "Time: %.1f" % max(time_remaining, 0.0)
	
	# Check if time is up
	if time_remaining <= 0.0:
		_on_time_up()

## Handle answer selection
func _on_answer_selected(option_index: int) -> void:
	if not game_running or option_index >= current_problem["options"].size():
		return
	
	var selected_answer = current_problem["options"][option_index]
	var is_correct = selected_answer == current_problem["correct_answer"]
	
	if is_correct:
		_on_correct_answer()
	else:
		_on_wrong_answer()

## Handle correct answer
func _on_correct_answer() -> void:
	var points = 10 * (int(GameManager.current_difficulty) + 1)
	
	# Apply teacher multiplier if active
	if FeatureConfig.teacher_mode:
		points = int(points * 0.5)  # Wrong answers in teacher mode give reduced points
	
	current_score += points
	score_label.text = "Score: %d" % current_score
	
	GameManager.problems_answered += 1
	
	# Play sound and animations
	_play_correct_feedback()
	
	# Check for win
	if current_score >= 100:
		_on_game_won()
	else:
		_generate_new_problem()

## Handle wrong answer
func _on_wrong_answer() -> void:
	_play_wrong_feedback()
	GameManager.problems_answered += 1
	_generate_new_problem()

## Handle time up
func _on_time_up() -> void:
	_play_wrong_feedback()
	GameManager.problems_answered += 1
	_generate_new_problem()

## Game won
func _on_game_won() -> void:
	game_running = false
	
	# Disable answer buttons
	for button in answer_buttons:
		button.disabled = true
	
	# Complete the dungeon in adventure manager
	AdventureManager.complete_dungeon(current_dungeon_id, current_score, total_game_time)
	
	# Show victory dialog
	var dialog = AcceptDialog.new()
	dialog.title = "Dungeon Cleared!"
	var dungeon = AdventureManager.get_dungeon(current_dungeon_id)
	var rewards = dungeon.rewards if dungeon else {"energy": 0, "experience": 0}
	
	dialog.dialog_text = "You cleared the dungeon!\n\nScore: %d\nTime: %.1fs\n\nRewards:\n+ %d Energy\n+ %d Experience" % [
		current_score,
		total_game_time,
		rewards.get("energy", 0),
		rewards.get("experience", 0)
	]
	
	dialog.confirmed.connect(func(): get_tree().change_scene_to_file("res://scenes/adventure_map.tscn"))
	add_child(dialog)
	dialog.popup_centered()

## Play correct answer feedback
func _play_correct_feedback() -> void:
	# Visual feedback
	for button in answer_buttons:
		button.modulate = Color.GREEN
	
	await get_tree().create_timer(0.3).timeout
	for button in answer_buttons:
		button.modulate = Color.WHITE

## Play wrong answer feedback
func _play_wrong_feedback() -> void:
	# Visual feedback - screen shake
	var original_position = global_position
	for i in range(5):
		global_position = original_position + Vector2(randf_range(-5, 5), randf_range(-5, 5))
		await get_tree().create_timer(0.05).timeout
	global_position = original_position

## Handle energy changes
func _on_energy_changed(energy: int) -> void:
	if energy_label and energy_label.visible:
		energy_label.text = "Energy: %d/%d" % [energy, EnergySystem.get_max_energy()]

## Get formatted time
func _format_time(seconds: float) -> String:
	var mins = int(seconds) / 60
	var secs = int(seconds) % 60
	return "%02d:%02d" % [mins, secs]
