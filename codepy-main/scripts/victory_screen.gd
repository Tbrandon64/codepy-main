extends Control

var player_score: int = 0
var opponent_score: int = 0
var is_multiplayer: bool = false
var difficulty_text: String = "Easy"

func _ready() -> void:
	# Get scores from GameManager
	player_score = GameManager.score
	opponent_score = GameManager.opponent_score if GameManager.has_meta("opponent_score") else 0
	is_multiplayer = GameManager.has_meta("is_multiplayer")
	
	# Get difficulty as text
	var difficulty = GameManager.current_difficulty
	match difficulty:
		GameManager.Difficulty.EASY:
			difficulty_text = "Easy"
		GameManager.Difficulty.MEDIUM:
			difficulty_text = "Medium"
		GameManager.Difficulty.HARD:
			difficulty_text = "Hard"
	
	# Update labels
	$VBoxContainer/ScoreLabel.text = "Your Score: %d" % player_score
	if is_multiplayer:
		$VBoxContainer/OpponentLabel.text = "Opponent Score: %d" % opponent_score
		$VBoxContainer/OpponentLabel.show()
	else:
		$VBoxContainer/OpponentLabel.hide()
	
	# Display high score info
	_show_high_score_info()
	
	# Connect buttons
	$VBoxContainer/RestartBtn.pressed.connect(_on_restart_pressed)
	$VBoxContainer/MenuBtn.pressed.connect(_on_menu_pressed)
	
	# Animate title
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.set_ease(Tween.EASE_OUT)
	$VBoxContainer/Title.scale = Vector2.ZERO
	tween.tween_property($VBoxContainer/Title, "scale", Vector2.ONE, 0.8)
	
	# Save high score if in single-player
	if not is_multiplayer:
		HighScoreManager.save_score("Player", player_score, difficulty_text)

func _show_high_score_info() -> void:
	"""Display high score status"""
	if HighScoreManager.is_high_score(player_score):
		var rank = HighScoreManager.get_high_score_rank(player_score)
		if rank <= 10:
			$VBoxContainer/HighScoreLabel.text = "🏆 New High Score! Rank #%d" % rank
			$VBoxContainer/HighScoreLabel.add_theme_color_override("font_color", Color.YELLOW)
			$VBoxContainer/HighScoreLabel.show()
		else:
			$VBoxContainer/HighScoreLabel.hide()
	else:
		$VBoxContainer/HighScoreLabel.hide()

func _on_restart_pressed() -> void:
	GameManager.reset()
	get_tree().change_scene_to_file("res://scenes/difficulty_menu.tscn")

func _on_menu_pressed() -> void:
	GameManager.reset()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
