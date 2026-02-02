extends Node

## Audio Manager - Handles volume control and sound effects
## Features: Master volume, category-based volume, sound settings

var master_volume: float = 1.0
var music_volume: float = 1.0
var sfx_volume: float = 1.0
var enable_sound: bool = true

# Audio bus indices
var master_bus_idx: int = -1
var music_bus_idx: int = -1
var sfx_bus_idx: int = -1

# Cached audio streams
var _ding_stream: AudioStreamWAV
var _buzz_stream: AudioStreamWAV

func _ready() -> void:
	# Get audio bus indices
	var master_idx = AudioServer.get_bus_index("Master")
	if master_idx >= 0:
		master_bus_idx = master_idx
	else:
		master_bus_idx = 0
		print("WARNING: Master audio bus not found")
	
	var music_idx = AudioServer.get_bus_index("Music")
	music_bus_idx = music_idx if music_idx >= 0 else master_bus_idx
	
	var sfx_idx = AudioServer.get_bus_index("SFX")
	sfx_bus_idx = sfx_idx if sfx_idx >= 0 else master_bus_idx
	
	# Pre-generate procedural sounds
	_generate_cached_sounds()
	
	# Load audio settings from config
	load_audio_settings()

## Load audio settings from configuration
func load_audio_settings() -> void:
	if ConfigFileHandler:
		var loaded_master = ConfigFileHandler.load_setting("audio", "master_volume", 1.0)
		if loaded_master != null:
			master_volume = loaded_master
		
		var loaded_music = ConfigFileHandler.load_setting("audio", "music_volume", 1.0)
		if loaded_music != null:
			music_volume = loaded_music
		
		var loaded_sfx = ConfigFileHandler.load_setting("audio", "sfx_volume", 1.0)
		if loaded_sfx != null:
			sfx_volume = loaded_sfx
		
		var loaded_sound = ConfigFileHandler.load_setting("audio", "enable_sound", true)
		if loaded_sound != null:
			enable_sound = loaded_sound
	else:
		print("WARNING: ConfigFileHandler not available, using default audio settings")
		master_volume = 1.0
		music_volume = 1.0
		sfx_volume = 1.0
		enable_sound = true
	apply_volume_settings()

## Apply current volume settings to audio buses
func apply_volume_settings() -> void:
	if master_bus_idx < 0:
		print("WARNING: Master audio bus not available")
		return  # Audio buses not available
	
	if not enable_sound:
		if master_bus_idx >= 0:
			AudioServer.set_bus_mute(master_bus_idx, true)
		return
	
	if master_bus_idx >= 0:
		AudioServer.set_bus_mute(master_bus_idx, false)
		AudioServer.set_bus_volume_db(master_bus_idx, linear_to_db(master_volume))
	if music_bus_idx >= 0:
		AudioServer.set_bus_volume_db(music_bus_idx, linear_to_db(master_volume * music_volume))
	if sfx_bus_idx >= 0:
		AudioServer.set_bus_volume_db(sfx_bus_idx, linear_to_db(master_volume * sfx_volume))

## Set master volume (0.0 - 1.0)
func set_master_volume(volume: float) -> void:
	if volume >= 0.0 and volume <= 1.0:
		master_volume = volume
	else:
		master_volume = clamp(volume, 0.0, 1.0)
		print("WARNING: Volume out of range, clamped to [0.0, 1.0]")
	
	if ConfigFileHandler:
		var saved = ConfigFileHandler.save_setting("audio", "master_volume", master_volume)
		if not saved:
			print("WARNING: Failed to save master volume setting")
	
	apply_volume_settings()

## Set music volume (0.0 - 1.0)
func set_music_volume(volume: float) -> void:
	if volume >= 0.0 and volume <= 1.0:
		music_volume = volume
	else:
		music_volume = clamp(volume, 0.0, 1.0)
		print("WARNING: Volume out of range, clamped to [0.0, 1.0]")
	
	if ConfigFileHandler:
		var saved = ConfigFileHandler.save_setting("audio", "music_volume", music_volume)
		if not saved:
			print("WARNING: Failed to save music volume setting")
	
	apply_volume_settings()

## Set SFX volume (0.0 - 1.0)
func set_sfx_volume(volume: float) -> void:
	if volume >= 0.0 and volume <= 1.0:
		sfx_volume = volume
	else:
		sfx_volume = clamp(volume, 0.0, 1.0)
		print("WARNING: Volume out of range, clamped to [0.0, 1.0]")
	
	if ConfigFileHandler:
		var saved = ConfigFileHandler.save_setting("audio", "sfx_volume", sfx_volume)
		if not saved:
			print("WARNING: Failed to save SFX volume setting")
	
	apply_volume_settings()

## Toggle sound on/off
func set_sound_enabled(enabled: bool) -> void:
	enable_sound = enabled
	if ConfigFileHandler:
		var saved = ConfigFileHandler.save_setting("audio", "enable_sound", enabled)
		if not saved:
			print("WARNING: Failed to save sound enabled setting")
	else:
		print("WARNING: ConfigFileHandler not available")
	
	apply_volume_settings()

## Play "ding" sound for correct answers
func play_correct_sound() -> void:
	if not enable_sound:
		return
	if not _ding_stream:
		print("WARNING: Ding stream not loaded")
		return
	_play_stream(_ding_stream)

## Play "buzz" sound for wrong answers
func play_wrong_sound() -> void:
	if not enable_sound:
		return
	if not _buzz_stream:
		print("WARNING: Buzz stream not loaded")
		return
	_play_stream(_buzz_stream)

## Play audio stream and clean up
func _play_stream(stream: AudioStream) -> void:
	if not stream:
		print("WARNING: _play_stream received null stream")
		return
	
	var player = AudioStreamPlayer.new()
	if not player:
		print("WARNING: Failed to create AudioStreamPlayer")
		return
	
	add_child(player)
	if player is AudioStreamPlayer:
		player.bus = "SFX"
		player.stream = stream
		player.play()
		await player.finished
		player.queue_free()
	else:
		print("WARNING: Created player is not an AudioStreamPlayer")

## Generate cached sounds once at startup
func _generate_cached_sounds() -> void:
	_ding_stream = _create_wav_stream(800.0, 1200.0, 0.2, 0.3, false)
	_buzz_stream = _create_wav_stream(150.0, 150.0, 0.3, 0.25, true)
	
	if not _ding_stream:
		print("WARNING: Failed to generate ding sound, audio playback limited")
	if not _buzz_stream:
		print("WARNING: Failed to generate buzz sound, audio playback limited")

## Create WAV stream from sine wave parameters
## Parameters: frequency (Hz), duration (seconds), volume (0-1), is_buzz (bool)
func _create_wav_stream(freq_start: float, freq_end: float, duration: float, volume: float, is_buzz: bool) -> AudioStreamWAV:
	if freq_start <= 0 or freq_end <= 0 or duration <= 0 or volume <= 0:
		print("WARNING: _create_wav_stream received invalid parameters, returning null")
		return null
	
	var stream = AudioStreamWAV.new()
	if not stream:
		print("WARNING: Failed to create AudioStreamWAV")
		return null
	
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = 44100
	
	var sample_count = int(44100 * duration)
	if sample_count <= 0:
		print("WARNING: Invalid sample_count in _create_wav_stream")
		return null
	
	var buffer = PackedByteArray()
	buffer.resize(sample_count * 2)
	
	for i in range(sample_count):
		var t = float(i) / 44100.0
		var sample = 0.0
		
		if is_buzz:
			# Buzz logic: Fundamental + Overtone
			var fundamental = freq_start
			sample = (sin(2 * PI * fundamental * t) + 0.5 * sin(2 * PI * fundamental * 2 * t)) * volume
			sample *= exp(-t * 2) # Decay
		else:
			# Ding logic: Frequency sweep + Decay
			var freq = freq_start + (freq_end - freq_start) * (1 - exp(-t * 10))
			var envelope = exp(-t * 3)
			sample = sin(2 * PI * freq * t) * envelope * volume
		
		# Clamp and convert to 16-bit integer (-32768 to 32767)
		var val = int(clamp(sample, -1.0, 1.0) * 32767.0)
		buffer.encode_s16(i * 2, val)
	
	if buffer.is_empty():
		print("WARNING: Buffer is empty after data generation")
		return null
	
	stream.data = buffer
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
