extends Control

var current_problem: GameManager.MathProblem
var waiting_for_answer: bool = false
var game_start_time: float = 0.0
var game_duration: float = 60.0  # 60 seconds

func _ready() -> void:
	# Connect buttons
	$VBoxContainer/OptionsGrid/Option1Btn.pressed.connect(_on_option_selected.bindv([0]))
	$VBoxContainer/OptionsGrid/Option2Btn.pressed.connect(_on_option_selected.bindv([1]))
	$VBoxContainer/OptionsGrid/Option3Btn.pressed.connect(_on_option_selected.bindv([2]))
	$VBoxContainer/OptionsGrid/Option4Btn.pressed.connect(_on_option_selected.bindv([3]))
	$VBoxContainer/SubmitBtn.pressed.connect(_on_submit_pressed)
	$VBoxContainer/BackBtn.pressed.connect(_on_back_pressed)
	$ResultDialog.confirmed.connect(_on_result_confirmed)
	
	# Connect timer
	$GameTimer.timeout.connect(_on_game_timer_timeout)
	
	# Connect text input
	$VBoxContainer/AnswerInput.text_submitted.connect(_on_text_submitted)
	
	# Consume energy if enabled
	if FeatureConfig.energy_system_enabled:
		var difficulty_str = GameManager.Difficulty.keys()[GameManager.current_difficulty].to_lower()
		var cost = EnergySystem.calculate_energy_cost("single_player", difficulty_str)
		if not EnergySystem.consume_energy(cost, "game_start"):
			_show_error_dialog("Not enough energy to play. Please try again later.")
			return
	
	game_start_time = Time.get_ticks_msec() / 1000.0
	
	# Display initial problem
	_display_next_problem()

func _process(_delta: float) -> void:
	# Update timer display
	var elapsed = Time.get_ticks_msec() / 1000.0 - game_start_time
	var remaining = max(0, game_duration - elapsed)
	$VBoxContainer/Header/TimerLabel.text = "Time: %d" % int(remaining)
	
	# Change color when time is low
	if remaining <= 10:
		$VBoxContainer/Header/TimerLabel.add_theme_color_override("font_color", Color(1, 0, 0, 1))
	else:
		$VBoxContainer/Header/TimerLabel.add_theme_color_override("font_color", Color(1, 1, 0, 1))

## Display the current problem and its options
func _display_next_problem() -> void:
	# Generate new problem
	current_problem = GameManager.generate_problem()
	waiting_for_answer = true
	
	# Update difficulty label
	var difficulty_name = GameManager.Difficulty.keys()[GameManager.current_difficulty]
	$VBoxContainer/Header/DifficultyLabel.text = "Difficulty: %s" % difficulty_name
	
	# Update score label
	$VBoxContainer/Header/ScoreLabel.text = "Score: %d/%d" % [GameManager.score, GameManager.problems_answered]
	
	# Display problem
	$VBoxContainer/ProblemContainer/ProblemLabel.text = current_problem.problem_text
	
	# Clear text input
	$VBoxContainer/AnswerInput.text = ""
	$VBoxContainer/AnswerInput.placeholder_text = "Type your answer here..."
	$VBoxContainer/AnswerInput.editable = true
	
	# Enable submit button
	$VBoxContainer/SubmitBtn.disabled = false
	
	# Focus the text input for immediate typing
	$VBoxContainer/AnswerInput.grab_focus()
	
	# Display answer options
	var option_buttons = [
		$VBoxContainer/OptionsGrid/Option1Btn,
		$VBoxContainer/OptionsGrid/Option2Btn,
		$VBoxContainer/OptionsGrid/Option3Btn,
		$VBoxContainer/OptionsGrid/Option4Btn
	]
	
	for i in range(option_buttons.size()):
		option_buttons[i].text = str(current_problem.options[i])
		option_buttons[i].disabled = false

## Handle answer selection
func _on_option_selected(option_index: int) -> void:
	if not waiting_for_answer:
		return
	
	waiting_for_answer = false
	
	# Get selected answer
	var selected_answer = current_problem.options[option_index]
	var is_correct = GameManager.check_answer(selected_answer)
	
	# Show result
	var result_text = "Correct!" if is_correct else "Wrong!\nCorrect answer: %d" % current_problem.correct_answer
	var result_color = Color.GREEN if is_correct else Color.RED
	
	$ResultDialog/ResultLabel.text = result_text
	$ResultDialog/ResultLabel.add_theme_color_override("font_color", result_color)
	$ResultDialog.popup_centered()
	
	# Disable all buttons while showing result
	var option_buttons = [
		$VBoxContainer/OptionsGrid/Option1Btn,
		$VBoxContainer/OptionsGrid/Option2Btn,
		$VBoxContainer/OptionsGrid/Option3Btn,
		$VBoxContainer/OptionsGrid/Option4Btn
	]
	for btn in option_buttons:
		btn.disabled = true

## Handle text input submission (Enter key)
func _on_text_submitted(text: String) -> void:
	_submit_answer(text)

## Handle submit button press
func _on_submit_pressed() -> void:
	var answer_text = $VBoxContainer/AnswerInput.text.strip_edges()
	_submit_answer(answer_text)

## Process submitted answer
func _submit_answer(answer_text: String) -> void:
	if not waiting_for_answer or answer_text.is_empty():
		return
	
	# Try to parse as number
	var selected_answer = answer_text.to_int()
	if answer_text != str(selected_answer):
		# Not a valid number
		$VBoxContainer/AnswerInput.text = ""
		$VBoxContainer/AnswerInput.placeholder_text = "Please enter a number..."
		return
	
	waiting_for_answer = false
	
	# Check answer
	var is_correct = GameManager.check_answer(selected_answer)
	
	# Show result
	var result_text = "Correct!" if is_correct else "Wrong!\nCorrect answer: %d" % current_problem.correct_answer
	var result_color = Color.GREEN if is_correct else Color.RED
	
	$ResultDialog/ResultLabel.text = result_text
	$ResultDialog/ResultLabel.add_theme_color_override("font_color", result_color)
	$ResultDialog.popup_centered()
	
	# Disable input while showing result
	$VBoxContainer/AnswerInput.editable = false
	$VBoxContainer/SubmitBtn.disabled = true

## Handle result dialog confirmation
func _on_result_confirmed() -> void:
	# Re-enable input
	$VBoxContainer/AnswerInput.editable = true
	$VBoxContainer/SubmitBtn.disabled = false
	
	_display_next_problem()

## Go back to main menu
func _on_back_pressed() -> void:
	# Award energy based on performance if enabled
	if FeatureConfig.energy_system_enabled and GameManager.problems_answered > 0:
		var accuracy = float(GameManager.score) / float(GameManager.problems_answered)
		var bonus_energy = int(accuracy * 5.0)  # Max 5 energy bonus
		if bonus_energy > 0:
			EnergySystem.gain_energy(bonus_energy, "game_performance_bonus")
	
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
## Show error dialog
func _show_error_dialog(message: String) -> void:
	var dialog = AcceptDialog.new()
	dialog.title = "Error"
	dialog.dialog_text = message
	add_child(dialog)
	dialog.popup_centered()

## Handle game timer timeout
func _on_game_timer_timeout() -> void:
	# Game over - go to victory screen
	get_tree().change_scene_to_file("res://scenes/victory_screen.tscn")