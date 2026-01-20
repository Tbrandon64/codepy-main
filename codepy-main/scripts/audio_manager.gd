extends Node

## Audio Manager - Handles volume control and sound effects
## Features: Master volume, category-based volume, sound settings

class_name AudioManager

var master_volume: float = 1.0
var music_volume: float = 1.0
var sfx_volume: float = 1.0
var enable_sound: bool = true

# Audio bus indices
var master_bus_idx: int = -1
var music_bus_idx: int = -1
var sfx_bus_idx: int = -1

func _ready() -> void:
	# Get audio bus indices
	master_bus_idx = AudioServer.get_bus_index("Master")
	music_bus_idx = AudioServer.get_bus_index("Music") if AudioServer.get_bus_index("Music") != -1 else master_bus_idx
	sfx_bus_idx = AudioServer.get_bus_index("SFX") if AudioServer.get_bus_index("SFX") != -1 else master_bus_idx
	
	# Load audio settings from config
	load_audio_settings()

## Load audio settings from configuration
func load_audio_settings() -> void:
	master_volume = ConfigFileHandler.load_setting("audio", "master_volume", 1.0)
	music_volume = ConfigFileHandler.load_setting("audio", "music_volume", 1.0)
	sfx_volume = ConfigFileHandler.load_setting("audio", "sfx_volume", 1.0)
	enable_sound = ConfigFileHandler.load_setting("audio", "enable_sound", true)
	
	apply_volume_settings()

## Apply current volume settings to audio buses
func apply_volume_settings() -> void:
	if not enable_sound:
		AudioServer.set_bus_mute(master_bus_idx, true)
		return
	
	AudioServer.set_bus_mute(master_bus_idx, false)
	AudioServer.set_bus_volume_db(master_bus_idx, linear2db(master_volume))
	AudioServer.set_bus_volume_db(music_bus_idx, linear2db(master_volume * music_volume))
	AudioServer.set_bus_volume_db(sfx_bus_idx, linear2db(master_volume * sfx_volume))

## Set master volume (0.0 - 1.0)
func set_master_volume(volume: float) -> void:
	master_volume = clamp(volume, 0.0, 1.0)
	ConfigFileHandler.save_setting("audio", "master_volume", master_volume)
	apply_volume_settings()

## Set music volume (0.0 - 1.0)
func set_music_volume(volume: float) -> void:
	music_volume = clamp(volume, 0.0, 1.0)
	ConfigFileHandler.save_setting("audio", "music_volume", music_volume)
	apply_volume_settings()

## Set SFX volume (0.0 - 1.0)
func set_sfx_volume(volume: float) -> void:
	sfx_volume = clamp(volume, 0.0, 1.0)
	ConfigFileHandler.save_setting("audio", "sfx_volume", sfx_volume)
	apply_volume_settings()

## Toggle sound on/off
func set_sound_enabled(enabled: bool) -> void:
	enable_sound = enabled
	ConfigFileHandler.save_setting("audio", "enable_sound", enabled)
	apply_volume_settings()

## Play procedural "ding" sound for correct answer
func play_correct_sound() -> void:
	if not enable_sound:
		return
	
	var player = AudioStreamPlayer.new()
	add_child(player)
	player.bus = "SFX"
	player.stream = _generate_ding_sound()
	player.play()
	await player.finished
	player.queue_free()

## Play procedural "buzz" sound for wrong answer
func play_wrong_sound() -> void:
	if not enable_sound:
		return
	
	var player = AudioStreamPlayer.new()
	add_child(player)
	player.bus = "SFX"
	player.stream = _generate_buzz_sound()
	player.play()
	await player.finished
	player.queue_free()

## Generate ding sound programmatically
func _generate_ding_sound() -> AudioStreamGenerator:
	var stream = AudioStreamGenerator.new()
	stream.mix_rate = 44100
	
	var playback = stream.get_playback()
	var sample_count = int(44100 * 0.2)  # 0.2 seconds
	
	var frames = PackedVector2Array()
	for i in range(sample_count):
		var t = float(i) / 44100.0
		# Frequency sweep from 800Hz to 1200Hz with decay
		var freq = 800 + 400 * (1 - exp(-t * 10))
		var envelope = exp(-t * 3)  # Decay envelope
		var sample = sin(2 * PI * freq * t) * envelope * 0.3
		frames.append(Vector2(sample, sample))
	
	playback.push_buffer(frames)
	return stream

## Generate buzz sound programmatically
func _generate_buzz_sound() -> AudioStreamGenerator:
	var stream = AudioStreamGenerator.new()
	stream.mix_rate = 44100
	
	var playback = stream.get_playback()
	var sample_count = int(44100 * 0.3)  # 0.3 seconds
	
	var frames = PackedVector2Array()
	for i in range(sample_count):
		var t = float(i) / 44100.0
		# Lower frequency with more buzz (multiple overtones)
		var fundamental = 150
		var sample = (sin(2 * PI * fundamental * t) + 
					  0.5 * sin(2 * PI * fundamental * 2 * t)) * 0.25
		# Decay envelope
		sample *= exp(-t * 2)
		frames.append(Vector2(sample, sample))
	
	playback.push_buffer(frames)
	return stream

## Get current master volume
func get_master_volume() -> float:
	return master_volume

## Get current music volume
func get_music_volume() -> float:
	return music_volume

## Get current SFX volume
func get_sfx_volume() -> float:
	return sfx_volume

## Check if sound is enabled
func is_sound_enabled() -> bool:
	return enable_sound
