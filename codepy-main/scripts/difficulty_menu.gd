extends Control

func _ready() -> void:
	$VBoxContainer/EasyBtn.pressed.connect(_on_easy_pressed)
	$VBoxContainer/MediumBtn.pressed.connect(_on_medium_pressed)
	$VBoxContainer/HardBtn.pressed.connect(_on_hard_pressed)
	$VBoxContainer/BackBtn.pressed.connect(_on_back_pressed)
	
	# Style buttons with fonts
	_setup_button_styles()

func _setup_button_styles() -> void:
	var font_size = 28
	
	# Easy - Green
	_style_button($VBoxContainer/EasyBtn, Color(0, 1, 0, 1), font_size)
	
	# Medium - Yellow
	_style_button($VBoxContainer/MediumBtn, Color(1, 1, 0, 1), font_size)
	
	# Hard - Red
	_style_button($VBoxContainer/HardBtn, Color(1, 0, 0, 1), font_size)
	
	# Back - Gray
	_style_button($VBoxContainer/BackBtn, Color(0.5, 0.5, 0.5, 1), font_size)

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
	_start_game(GameManager.Difficulty.EASY)

func _on_medium_pressed() -> void:
	_start_game(GameManager.Difficulty.MEDIUM)

func _on_hard_pressed() -> void:
	_start_game(GameManager.Difficulty.HARD)

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _start_game(difficulty: GameManager.Difficulty) -> void:
	# Set difficulty in GameManager
	GameManager.set_difficulty(difficulty)
	GameManager.reset()
	
	# Generate first problem
	var problem = GameManager.generate_problem()
	
	# Load game scene
	get_tree().change_scene_to_file("res://scenes/game.tscn")
