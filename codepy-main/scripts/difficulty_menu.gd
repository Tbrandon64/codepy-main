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
	
	for button in [$VBoxContainer/EasyBtn, $VBoxContainer/MediumBtn, 
				   $VBoxContainer/HardBtn, $VBoxContainer/BackBtn]:
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
	get_tree().change_scene_to_file("res://scenes/game_scene.tscn")
