extends Control

func _ready() -> void:
	print("DifficultyMenu._ready() called")
	
	var easy_btn = get_node_or_null("VBoxContainer/EasyBtn")
	var medium_btn = get_node_or_null("VBoxContainer/MediumBtn")
	var hard_btn = get_node_or_null("VBoxContainer/HardBtn")
	var back_btn = get_node_or_null("VBoxContainer/BackBtn")
	
	print("Easy button found: ", easy_btn != null)
	print("Medium button found: ", medium_btn != null)
	print("Hard button found: ", hard_btn != null)
	print("Back button found: ", back_btn != null)
	
	if easy_btn:
		easy_btn.pressed.connect(_on_easy_pressed)
	if medium_btn:
		medium_btn.pressed.connect(_on_medium_pressed)
	if hard_btn:
		hard_btn.pressed.connect(_on_hard_pressed)
	if back_btn:
		back_btn.pressed.connect(_on_back_pressed)
	
	# Style buttons with fonts
	_setup_button_styles()

func _setup_button_styles() -> void:
	var font_size = 28
	
	var easy_btn = get_node_or_null("VBoxContainer/EasyBtn")
	var medium_btn = get_node_or_null("VBoxContainer/MediumBtn")
	var hard_btn = get_node_or_null("VBoxContainer/HardBtn")
	var back_btn = get_node_or_null("VBoxContainer/BackBtn")
	
	# Easy - Green
	if easy_btn:
		_style_button(easy_btn, Color(0, 1, 0, 1), font_size)
	
	# Medium - Yellow
	if medium_btn:
		_style_button(medium_btn, Color(1, 1, 0, 1), font_size)
	
	# Hard - Red
	if hard_btn:
		_style_button(hard_btn, Color(1, 0, 0, 1), font_size)
	
	# Back - Gray
	if back_btn:
		_style_button(back_btn, Color(0.5, 0.5, 0.5, 1), font_size)

func _style_button(button: Button, color: Color, font_size: int) -> void:
	var style = StyleBoxFlat.new()
	style.bg_color = color
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = color.lightened(0.3)
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_right = 4
	style.corner_radius_bottom_left = 4
	
	button.add_theme_stylebox_override("normal", style)
	button.add_theme_stylebox_override("hover", style.duplicate())
	button.add_theme_font_size_override("font_size", font_size)
	button.add_theme_color_override("font_color", Color.WHITE)

func _on_easy_pressed() -> void:
	print("EASY button pressed - starting game with EASY difficulty")
	_start_game(GameManager.Difficulty.EASY)

func _on_medium_pressed() -> void:
	print("MEDIUM button pressed - starting game with MEDIUM difficulty")
	_start_game(GameManager.Difficulty.MEDIUM)

func _on_hard_pressed() -> void:
	print("HARD button pressed - starting game with HARD difficulty")
	_start_game(GameManager.Difficulty.HARD)

func _on_back_pressed() -> void:
	print("BACK button pressed - returning to main menu")
	var error = get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	if error != OK:
		print("ERROR loading main menu: ", error)

func _start_game(difficulty: GameManager.Difficulty) -> void:
	print("_start_game() called with difficulty: ", difficulty)
	# Set difficulty in GameManager
	GameManager.set_difficulty(difficulty)
	GameManager.reset()
	
	# Generate first problem
	var problem = GameManager.generate_problem()
	print("Generated problem: ", problem.problem_text if problem else "NULL")
	
	# Load game scene
	print("Loading game_new.tscn...")
	var error = get_tree().change_scene_to_file("res://scenes/game_new.tscn")
	if error != OK:
		print("ERROR loading game_new.tscn: ", error)
