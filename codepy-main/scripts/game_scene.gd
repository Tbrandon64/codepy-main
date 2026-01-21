extends CanvasLayer

# Scoring and game state
var player_score: int = 0
var opponent_score: int = 0
var time_remaining: int = 15
var current_problem: GameManager.MathProblem
var is_multiplayer: bool = false
var is_host: bool = false
var is_waiting_for_result: bool = false
var connection_lost: bool = false
var is_paused: bool = false
var win_score: int = 100

func _ready() -> void:
	# Check if multiplayer
	is_multiplayer = multiplayer.multiplayer_peer != null and multiplayer.get_peers().size() > 0
	is_host = multiplayer.is_server() if is_multiplayer else false
	
	# Connect multiplayer disconnect signal
	if is_multiplayer:
		multiplayer.server_disconnected.connect(_on_server_disconnected)
		multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	
	# Connect button signals
	$UI/VBoxContainer/OptionsGrid/Option1Btn.pressed.connect(_on_option_pressed.bindv([0]))
	$UI/VBoxContainer/OptionsGrid/Option2Btn.pressed.connect(_on_option_pressed.bindv([1]))
	$UI/VBoxContainer/OptionsGrid/Option3Btn.pressed.connect(_on_option_pressed.bindv([2]))
	$UI/VBoxContainer/OptionsGrid/Option4Btn.pressed.connect(_on_option_pressed.bindv([3]))
	
	# Connect timers
	$GameTimer.timeout.connect(_on_game_timer_timeout)
	$ResultTimer.timeout.connect(_on_result_timer_timeout)
	$WrongShake.timeout.connect(_on_wrong_shake_timeout)
	
	# Connect pause menu
	$PauseMenu/PauseVBox/ResumeBtn.pressed.connect(_on_resume_pressed)
	$PauseMenu/PauseVBox/QuitBtn.pressed.connect(_on_quit_pressed)
	
	# Setup button hover animations
	_setup_button_animations()
	
	# Start first problem
	_display_next_problem()
	_start_countdown()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().root.set_input_as_handled()
		if is_paused:
			_on_resume_pressed()
		else:
			_pause_game()

## Setup button hover animations
func _setup_button_animations() -> void:
	var buttons = [
		$UI/VBoxContainer/OptionsGrid/Option1Btn,
		$UI/VBoxContainer/OptionsGrid/Option2Btn,
		$UI/VBoxContainer/OptionsGrid/Option3Btn,
		$UI/VBoxContainer/OptionsGrid/Option4Btn
	]
	
	for btn in buttons:
		btn.mouse_entered.connect(func(): _animate_button_hover(btn, true))
		btn.mouse_exited.connect(func(): _animate_button_hover(btn, false))

## Animate button on hover
func _animate_button_hover(button: Button, is_hovering: bool) -> void:
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	
	if is_hovering:
		tween.tween_property(button, "scale", Vector2(1.1, 1.1), 0.2)
	else:
		tween.tween_property(button, "scale", Vector2.ONE, 0.2)

## Display the next problem
func _display_next_problem() -> void:
	if connection_lost or is_paused:
		return
	
	# Host generates the problem
	if is_host or not is_multiplayer:
		current_problem = GameManager.generate_problem()
		
		# Sync to client if multiplayer
		if is_multiplayer:
			_sync_problem.rpc(current_problem.problem_text, current_problem.options, current_problem.correct_answer)
		else:
			_display_problem_local()
	
	# Reset timer and status
	time_remaining = 15
	$UI/VBoxContainer/StatusLabel.text = ""
	is_waiting_for_result = false

## Display problem on local screen
func _display_problem_local() -> void:
	$UI/VBoxContainer/ProblemLabel.text = current_problem.problem_text
	
	var option_buttons = [
		$UI/VBoxContainer/OptionsGrid/Option1Btn,
		$UI/VBoxContainer/OptionsGrid/Option2Btn,
		$UI/VBoxContainer/OptionsGrid/Option3Btn,
		$UI/VBoxContainer/OptionsGrid/Option4Btn
	]
	
	for i in range(option_buttons.size()):
		option_buttons[i].text = str(current_problem.options[i])
		option_buttons[i].disabled = false
		option_buttons[i].scale = Vector2.ONE

## Start countdown timer
func _start_countdown() -> void:
	$GameTimer.start()

## Called every second by GameTimer
func _on_game_timer_timeout() -> void:
	if is_paused:
		return
	
	time_remaining -= 1
	$UI/VBoxContainer/TimerLabel.text = "%ds" % time_remaining
	
	# Time's up - show correct answer and advance
	if time_remaining <= 0:
		$GameTimer.stop()
		_on_time_expired()

## Handle time expired (no answer given)
func _on_time_expired() -> void:
	if connection_lost or is_waiting_for_result:
		return
	
	is_waiting_for_result = true
	
	# Show correct answer in status
	$UI/VBoxContainer/StatusLabel.text = "Time's up! Answer: %d" % current_problem.correct_answer
	$UI/VBoxContainer/StatusLabel.add_theme_color_override("font_color", Color.RED)
	
	# Disable all buttons
	_disable_all_buttons()
	
	# AI opponent acts if single-player
	if not is_multiplayer:
		_ai_opponent_answer()
	
	# Wait 1 second before next problem
	$ResultTimer.start()

## Handle option button press
func _on_option_pressed(option_index: int) -> void:
	if is_waiting_for_result or connection_lost or is_paused:
		return
	
	is_waiting_for_result = true
	$GameTimer.stop()
	
	# Get selected answer
	var selected_answer = current_problem.options[option_index]
	var is_correct = selected_answer == current_problem.correct_answer
	
	# Update player score
	if is_correct:
		var points = 10 * (GameManager.current_difficulty + 1)
		player_score += points
		$UI/VBoxContainer/StatusLabel.text = "Correct! +%d" % points
		$UI/VBoxContainer/StatusLabel.add_theme_color_override("font_color", Color.GREEN)
		
		# Play correct sound
		_play_correct_sound()
		
		# Show particle effect
		_show_correct_particles()
		
		# Animate score
		_animate_score_pop($UI/VBoxContainer/ScoreBox/YourScoreLabel)
	else:
		$UI/VBoxContainer/StatusLabel.text = "Wrong! Answer: %d" % current_problem.correct_answer
		$UI/VBoxContainer/StatusLabel.add_theme_color_override("font_color", Color.RED)
		
		# Play wrong sound
		_play_wrong_sound()
		
		# Shake effect
		_shake_screen()
	
	# Update display
	_update_scores()
	
	# Disable all buttons
	_disable_all_buttons()
	
	# Single-player or multiplayer handling
	if not is_multiplayer:
		_ai_opponent_answer()
	else:
		# Send answer to opponent (host authority will sync)
		_sync_answer.rpc_id(1, is_correct, player_score)
	
	# Check for win condition
	if player_score >= win_score:
		_show_victory()
		return
	
	# Wait 1 second before next problem
	$ResultTimer.start()

## Disable all option buttons
func _disable_all_buttons() -> void:
	var option_buttons = [
		$UI/VBoxContainer/OptionsGrid/Option1Btn,
		$UI/VBoxContainer/OptionsGrid/Option2Btn,
		$UI/VBoxContainer/OptionsGrid/Option3Btn,
		$UI/VBoxContainer/OptionsGrid/Option4Btn
	]
	for btn in option_buttons:
		btn.disabled = true

## AI opponent randomly answers (single-player only)
func _ai_opponent_answer() -> void:
	# AI has 70% chance of correct, 30% wrong
	var is_correct = randf() < 0.7
	
	if is_correct:
		var points = 10 * (GameManager.current_difficulty + 1)
		opponent_score += points
	
	_update_scores()
	
	# Check for opponent win
	if opponent_score >= win_score:
		_on_opponent_victory()
		return

## Update score display
func _update_scores() -> void:
	$UI/VBoxContainer/ScoreBox/YourScoreLabel.text = "Your Score: %d" % player_score
	$UI/VBoxContainer/ScoreBox/OpponentScoreLabel.text = "Opponent Score: %d" % opponent_score

## Called when result timer times out (1 second delay)
func _on_result_timer_timeout() -> void:
	_display_next_problem()
	if not connection_lost and not is_paused:
		_display_problem_local()
		_start_countdown()

# ============ ANIMATION & EFFECTS ============

## Play correct sound
func _play_correct_sound() -> void:
	# Create a simple sine wave sound (or load an audio file)
	if not $CorrectSound.stream:
		_create_ding_sound()
	$CorrectSound.play()

## Play wrong sound
func _play_wrong_sound() -> void:
	# Create a buzz sound or load audio
	if not $WrongSound.stream:
		_create_buzz_sound()
	$WrongSound.play()

## Create procedural ding sound
func _create_ding_sound() -> void:
	var audio_stream = AudioStreamGenerator.new()
	audio_stream.mix_rate = 44100
	var playback = audio_stream.get_playback()
	
	var sample_count = 44100 * 0.2  # 200ms
	for i in range(int(sample_count)):
		var t = float(i) / 44100.0
		var freq = 800 + sin(t * 20) * 100
		var sample = sin(t * freq * TAU) * (0.5 * exp(-t * 3))
		playback.push_frame(Vector2(sample, sample))
	
	$CorrectSound.stream = audio_stream

## Create procedural buzz sound
func _create_buzz_sound() -> void:
	var audio_stream = AudioStreamGenerator.new()
	audio_stream.mix_rate = 44100
	var playback = audio_stream.get_playback()
	
	var sample_count = 44100 * 0.3  # 300ms
	for i in range(int(sample_count)):
		var t = float(i) / 44100.0
		var sample = (randf() * 2 - 1) * 0.3 * (1.0 - t)  # White noise with fade
		playback.push_frame(Vector2(sample, sample))
	
	$WrongSound.stream = audio_stream

## Show particle effect for correct answer
func _show_correct_particles() -> void:
	$CorrectParticles.position = Vector2(512, 300)
	$CorrectParticles.emitting = true

## Shake screen on wrong answer
func _shake_screen() -> void:
	var original_pos = $UI.position
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	
	for i in range(4):
		var offset = Vector2(randf_range(-10, 10), randf_range(-10, 10))
		tween.tween_property($UI, "position", original_pos + offset, 0.05)
	
	tween.tween_property($UI, "position", original_pos, 0.05)

func _on_wrong_shake_timeout() -> void:
	pass

## Animate score popup when score changes
func _animate_score_pop(label: Label) -> void:
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.set_ease(Tween.EASE_OUT)
	
	label.scale = Vector2.ONE
	tween.tween_property(label, "scale", Vector2(1.3, 1.3), 0.3)
	tween.tween_property(label, "scale", Vector2.ONE, 0.3)

## Show victory screen
func _show_victory() -> void:
	GameManager.score = player_score
	if is_multiplayer:
		GameManager.set_meta("opponent_score", opponent_score)
	GameManager.set_meta("is_multiplayer", is_multiplayer)
	
	$GameTimer.stop()
	$ResultTimer.stop()
	
	get_tree().change_scene_to_file("res://scenes/victory_screen.tscn")

## Show opponent victory (single-player)
func _on_opponent_victory() -> void:
	var dialog = AcceptDialog.new()
	dialog.title = "Game Over"
	dialog.dialog_text = "Opponent reached 100 points first!\n\nYour Score: %d\nOpponent Score: %d" % [player_score, opponent_score]
	add_child(dialog)
	dialog.confirmed.connect(func():
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	)
	dialog.popup_centered_ratio(0.6)

## Pause game
func _pause_game() -> void:
	is_paused = true
	$GameTimer.stop()
	$PauseMenu.visible = true

## Resume game
func _on_resume_pressed() -> void:
	is_paused = false
	$PauseMenu.visible = false
	$GameTimer.start()

## Quit to menu
func _on_quit_pressed() -> void:
	multiplayer.multiplayer_peer = null
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

# ============ MULTIPLAYER RPC METHODS ============

## Sync problem to all players (authority: host only)
@rpc("authority", "call_local", "reliable")
func _sync_problem(problem_text: String, options_array: Array, correct_answer: int) -> void:
	# Store problem data locally
	current_problem = GameManager.MathProblem.new()
	current_problem.problem_text = problem_text
	current_problem.options = options_array
	current_problem.correct_answer = correct_answer
	
	# Display problem
	_display_problem_local()

## Sync answer result from player (authority: host)
@rpc("authority", "call_local", "reliable")
func _sync_answer(is_correct: bool, player_pts: int) -> void:
	# Update opponent score based on their answer
	if is_correct:
		var points = 10 * (GameManager.current_difficulty + 1)
		opponent_score = player_pts
	
	_update_scores()

# ============ MULTIPLAYER DISCONNECT HANDLERS ============

func _on_server_disconnected() -> void:
	# Client lost connection to server
	if connection_lost:
		return
	
	connection_lost = true
	$GameTimer.stop()
	$ResultTimer.stop()
	
	_show_connection_lost()

func _on_peer_disconnected(peer_id: int) -> void:
	# Host detected client disconnect
	if connection_lost:
		return
	
	connection_lost = true
	$GameTimer.stop()
	$ResultTimer.stop()
	
	_show_connection_lost()

func _show_connection_lost() -> void:
	# Reset networking
	multiplayer.multiplayer_peer = null
	
	var dialog = AcceptDialog.new()
	dialog.title = "Connection Lost"
	dialog.dialog_text = "Lost connection to opponent.\n\nReturning to main menu..."
	add_child(dialog)
	dialog.confirmed.connect(func(): 
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	)
	dialog.popup_centered_ratio(0.6)
