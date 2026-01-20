# MathBlat Polish Features - Code & Assets Guide

## Features Implemented

### 1. Sound Effects

**Procedural Audio Generation** (no external files needed):
- **Ding Sound**: 800Hz sine wave with frequency modulation, 200ms duration
- **Buzz Sound**: White noise with envelope decay, 300ms duration

```gdscript
## Create procedural ding sound (correct answer)
func _create_ding_sound() -> void:
	var audio_stream = AudioStreamGenerator.new()
	audio_stream.mix_rate = 44100
	var playback = audio_stream.get_playback()
	
	var sample_count = 44100 * 0.2  # 200ms
	for i in range(int(sample_count)):
		var t = float(i) / 44100.0
		var freq = 800 + sin(t * 20) * 100  # Frequency sweep
		var sample = sin(t * freq * TAU) * (0.5 * exp(-t * 3))  # Exponential decay
		playback.push_frame(Vector2(sample, sample))
	
	$CorrectSound.stream = audio_stream
	$CorrectSound.play()

## Create procedural buzz sound (wrong answer)
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
	$WrongSound.play()
```

**To use external audio files**, replace with:
```gdscript
# Load from res://assets/sounds/
$CorrectSound.stream = load("res://assets/sounds/ding.ogg")
$WrongSound.stream = load("res://assets/sounds/buzz.ogg")
```

---

### 2. Particle Effects

**Green Explosion (Correct)** - Add to `game_scene.tscn`:
```gdscript
[node name="CorrectParticles" type="Particle2D" parent="."]
position = Vector2(512, 300)
emitting = false
initial_velocity_min = 100
initial_velocity_max = 300
gravity = Vector2.ZERO
randomize_speed = 0.5

# Particle Emission:
amount = 24
lifetime = 0.8
emit_angle = 0  # Full circle
emit_angle_variance = 180

# Particle Visual:
modulate = Color(0, 1, 0, 0.8)  # Green
scale = 2.0

# Particle Scale Tween:
scale_amount_min = 0.5
scale_amount_max = 2.0
scale_amount_curve = 
angle_min = 0
angle_max = 360
```

**Script to trigger**:
```gdscript
func _show_correct_particles() -> void:
	$CorrectParticles.position = Vector2(512, 300)
	$CorrectParticles.emitting = true
```

**Red Shake (Wrong)** - Already implemented with Tween:
```gdscript
func _shake_screen() -> void:
	var original_pos = $UI.position
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	
	for i in range(4):
		var offset = Vector2(randf_range(-10, 10), randf_range(-10, 10))
		tween.tween_property($UI, "position", original_pos + offset, 0.05)
	
	tween.tween_property($UI, "position", original_pos, 0.05)
```

---

### 3. Button Hover Animations (Tween)

```gdscript
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
	tween.set_trans(Tween.TRANS_CUBIC)  # Easing: cubic
	tween.set_ease(Tween.EASE_OUT)
	
	if is_hovering:
		tween.tween_property(button, "scale", Vector2(1.1, 1.1), 0.2)  # Scale up 10%
	else:
		tween.tween_property(button, "scale", Vector2.ONE, 0.2)  # Scale back to 1.0
```

**Score Pop-In Animation** (on score update):
```gdscript
func _animate_score_pop(label: Label) -> void:
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.set_ease(Tween.EASE_OUT)
	
	label.scale = Vector2.ONE
	tween.tween_property(label, "scale", Vector2(1.3, 1.3), 0.3)  # Bounce up
	tween.tween_property(label, "scale", Vector2.ONE, 0.3)  # Bounce back
```

---

### 4. Pause Menu (Esc Key)

**Scene Structure** (already in `game_scene.tscn`):
```gdscene
[node name="PauseMenu" type="Control"]
visible = false
layout_mode = 3

[node name="PauseOverlay" type="ColorRect"]
color = Color(0, 0, 0, 0.7)  # 70% black overlay

[node name="PauseVBox" type="VBoxContainer"]
# PAUSED title + Resume/Quit buttons
```

**Script Handler**:
```gdscript
var is_paused: bool = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):  # ESC key
		get_tree().root.set_input_as_handled()
		if is_paused:
			_on_resume_pressed()
		else:
			_pause_game()

func _pause_game() -> void:
	is_paused = true
	$GameTimer.stop()
	$PauseMenu.visible = true

func _on_resume_pressed() -> void:
	is_paused = false
	$PauseMenu.visible = false
	$GameTimer.start()

func _on_quit_pressed() -> void:
	multiplayer.multiplayer_peer = null
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
```

---

### 5. Win Condition (First to 100 Points)

**Victory Screen** (`victory_screen.tscn`):
- Displays final scores
- "Play Again" button → restart difficulty menu
- "Main Menu" button → return to main menu
- Animated elastic title pop-in

**Trigger in game**:
```gdscript
var win_score: int = 100

func _on_option_pressed(option_index: int) -> void:
	# ... answer logic ...
	
	# Check for win condition
	if player_score >= win_score:
		_show_victory()
		return

func _show_victory() -> void:
	GameManager.score = player_score
	if is_multiplayer:
		GameManager.set_meta("opponent_score", opponent_score)
	
	$GameTimer.stop()
	$ResultTimer.stop()
	
	get_tree().change_scene_to_file("res://scenes/victory_screen.tscn")
```

---

## Free Asset Recommendations

### Sound Effects
**Use procedural generation** (implemented above) OR:
- **OpenGameArt.org**: Search "ding", "buzz", "correct", "wrong"
  - Format: `.ogg` or `.wav` (place in `res://assets/sounds/`)
  - Freesound.org: https://freesound.org/search/?q=ding+sound

### Particle Textures (Stars)
```gdscene
# For scrolling star background:
[node name="ParallaxBackground" type="ParallaxBackground"]
[node name="ParallaxLayer" type="ParallaxLayer"]
motion_scale = 0.5  # Parallax depth

[node name="StarSprite" type="Sprite2D"]
texture = load("res://assets/textures/star.png")
offset = Vector2(512, 300)
```

**Star texture options**:
- OpenGameArt.org: "stars", "space", "2d tile"
- Create simple star: White circle (16x16px) + blur
- Godot built-in: Use `CircleShape2D` or simple quad with shader

### Particle Material (Green Explosion)
```gdscript
var particle_material = StandardMaterial3D.new()
particle_material.albedo_color = Color(0, 1, 0, 0.8)  # Green
particle_material.transparency = StandardMaterial3D.TRANSPARENCY_ALPHA
```

---

## Tween Reference (Common Patterns)

```gdscript
# Basic scale animation
var tween = create_tween()
tween.tween_property(node, "scale", Vector2(2, 2), 0.5)

# Chained animations
var tween = create_tween()
tween.tween_property(node, "position", Vector2(100, 100), 0.5)
tween.tween_property(node, "rotation", PI, 0.5)

# Parallel animations
var tween = create_tween()
tween.set_parallel(true)
tween.tween_property(node, "position", Vector2(100, 100), 0.5)
tween.tween_property(node, "scale", Vector2(2, 2), 0.5)

# With easing
var tween = create_tween()
tween.set_trans(Tween.TRANS_CUBIC)
tween.set_ease(Tween.EASE_OUT)
tween.tween_property(node, "scale", Vector2(1.5, 1.5), 0.3)

# Loops
var tween = create_tween()
tween.set_loops()  # Infinite
tween.tween_property(node, "rotation", TAU, 2.0)

# Callbacks
var tween = create_tween()
tween.tween_callback(func(): print("Animation done"))
```

---

## Easing Functions (Tween.TRANS_*)
- `TRANS_LINEAR`: Constant speed
- `TRANS_SINE`: Smooth sine curve
- `TRANS_QUAD`: Quadratic acceleration
- `TRANS_CUBIC`: Cubic (smoother)
- `TRANS_QUART`: Quartic
- `TRANS_QUINT`: Quintic
- `TRANS_EXPO`: Exponential
- `TRANS_CIRC`: Circular
- `TRANS_ELASTIC`: Spring/bounce
- `TRANS_BACK`: Overshoot
- `TRANS_BOUNCE`: Bouncy

With `EASE_IN`, `EASE_OUT`, or `EASE_INOUT`

---

## AudioStreamPlayer Usage

```gdscript
# In scene: Add AudioStreamPlayer node named "SoundEffect"

# Play sound
$SoundEffect.play()

# Set volume (dB scale: -80 to 0)
$SoundEffect.volume_db = -10  # Quieter
$SoundEffect.volume_db = 0    # Full volume

# Stop sound
$SoundEffect.stop()

# Check if playing
if $SoundEffect.playing:
	print("Sound is playing")

# Fade out
var tween = create_tween()
tween.tween_property($SoundEffect, "volume_db", -80, 1.0)
tween.tween_callback($SoundEffect.stop)
```

---

## File Structure for Assets

```
res://
├── assets/
│   ├── sounds/
│   │   ├── ding.ogg
│   │   └── buzz.ogg
│   ├── textures/
│   │   ├── star.png
│   │   └── particle_spark.png
│   └── fonts/
│       └── arial_bold.tres
├── scenes/
├── scripts/
└── project.godot
```

---

## Next Steps

1. **Import Free Assets**:
   - Download from OpenGameArt.org or Freesound.org
   - Place in `res://assets/sounds/` and `res://assets/textures/`
   - Update scene references: `load("res://assets/sounds/ding.ogg")`

2. **Custom Particle Effects**:
   - Edit `CorrectParticles` node in `game_scene.tscn`
   - Adjust velocity, color, lifetime, emission

3. **Background Stars**:
   - Add `ParallexBackground` with tiling `Star` sprites
   - Use shader for smooth scrolling parallax

4. **UI Polish**:
   - Add hover tooltips to buttons
   - Animate menu transitions
   - Add screen fade effects

5. **Sound Configuration**:
   - Adjust volume_db in AudioStreamPlayer
   - Add background music autoload
   - Implement mute toggle
