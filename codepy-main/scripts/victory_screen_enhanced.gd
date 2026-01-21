extends Control

## Victory Screen Enhanced with Confetti, Share, and High Score Celebration

@onready var score_label = $VBoxContainer/ScoreLabel
@onready var high_score_marker = $VBoxContainer/HighScoreMarker
@onready var share_button = $VBoxContainer/ShareButton
@onready var again_button = $VBoxContainer/AgainButton
@onready var confetti_particles = $ConfettiParticles
@onready var share_dialog = $ShareDialog

var current_score: int = 0
var is_new_high_score: bool = false

func _ready() -> void:
	score_label.text = "Score: 0"
	share_button.pressed.connect(_on_share_pressed)
	again_button.pressed.connect(_on_play_again)
	
	# Start confetti if high score
	_check_high_score()

func set_score(score: int) -> void:
	current_score = score
	score_label.text = "Score: %d" % score
	_check_high_score()

func _check_high_score() -> void:
	if HighScoreManager:
		var previous_high = HighScoreManager.get_high_score()
		
		if current_score > previous_high:
			is_new_high_score = true
			HighScoreManager.save_high_score(current_score)
			_show_high_score_celebration()
		else:
			is_new_high_score = false
			high_score_marker.visible = false

func _show_high_score_celebration() -> void:
	# Show "NEW HIGH SCORE" text
	high_score_marker.visible = true
	high_score_marker.text = "🎉 NEW HIGH SCORE! 🎉"
	high_score_marker.modulate = Color.YELLOW
	
	# Start confetti burst
	if confetti_particles:
		confetti_particles.emitting = true
		
		# Stop after 5 seconds
		await get_tree().create_timer(5.0).timeout
		confetti_particles.emitting = false

func _on_share_pressed() -> void:
	if current_score < 100:
		share_button.text = "Score too low to share!"
		await get_tree().create_timer(2.0).timeout
		share_button.text = "📢 SHARE SCORE"
		return
	
	_show_share_options()

func _show_share_options() -> void:
	var score_text = "I just scored %d points in Math Blast! 🚀 Can you beat me? Download free on itch.io!" % current_score
	
	# Copy to clipboard
	DisplayServer.clipboard_set(score_text)
	
	# Show dialog
	share_dialog.visible = true
	share_dialog.title = "Share Your Score!"
	
	var message = "Score text copied to clipboard!\n\n"
	message += score_text + "\n\n"
	message += "Tweet it, paste it to Discord, or share anywhere!"
	
	share_dialog.dialog_text = message
	share_dialog.show()

func _on_play_again() -> void:
	get_tree().reload_current_scene()

# Confetti particle setup - add this as child node
func _setup_confetti() -> void:
	if not confetti_particles:
		confetti_particles = GPUParticles2D.new()
		confetti_particles.name = "ConfettiParticles"
		confetti_particles.position = Vector2(400, 300)
		confetti_particles.amount = 50
		confetti_particles.lifetime = 3.0
		add_child(confetti_particles)
		
		# Create particle material
		var material = ParticleProcessMaterial.new()
		material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
		material.emission_box_extents = Vector3(400, 0, 0)
		material.initial_velocity_min = 100
		material.initial_velocity_max = 300
		material.gravity = Vector3(0, 500, 0)
		
		confetti_particles.process_material = material
