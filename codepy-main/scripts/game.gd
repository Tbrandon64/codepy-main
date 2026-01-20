extends Control

var current_problem: GameManager.MathProblem
var waiting_for_answer: bool = false

func _ready() -> void:
	# Connect buttons
	$VBoxContainer/OptionsGrid/Option1Btn.pressed.connect(_on_option_selected.bindv([0]))
	$VBoxContainer/OptionsGrid/Option2Btn.pressed.connect(_on_option_selected.bindv([1]))
	$VBoxContainer/OptionsGrid/Option3Btn.pressed.connect(_on_option_selected.bindv([2]))
	$VBoxContainer/OptionsGrid/Option4Btn.pressed.connect(_on_option_selected.bindv([3]))
	$VBoxContainer/BackBtn.pressed.connect(_on_back_pressed)
	$ResultDialog.confirmed.connect(_on_result_confirmed)
	
	# Display initial problem
	_display_next_problem()

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

## Handle result dialog confirmation
func _on_result_confirmed() -> void:
	_display_next_problem()

## Go back to main menu
func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
