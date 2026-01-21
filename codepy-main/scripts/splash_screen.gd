extends CanvasLayer

## Splash Screen - Shows MB rocket logo on startup
## Duration: 1 second fade-in/out

@onready var splash_rect = $ColorRect
@onready var logo = $CenterContainer/Logo

func _ready() -> void:
	splash_rect.color = Color.BLACK
	logo.modulate.a = 0.0
	
	# Fade in
	var tween = create_tween()
	tween.tween_property(logo, "modulate:a", 1.0, 0.5)
	
	# Display for 1 second
	await get_tree().create_timer(1.0).timeout
	
	# Fade out
	tween = create_tween()
	tween.tween_property(logo, "modulate:a", 0.0, 0.5)
	
	await get_tree().create_timer(0.5).timeout
	queue_free()

func draw_mb_rocket() -> void:
	# Draw rocket "MB" logo (simple ASCII art for now)
	var draw_label = Label.new()
	draw_label.text = "🚀\nMB"
	draw_label.add_theme_font_size_override("font_size", 120)
	add_child(draw_label)
