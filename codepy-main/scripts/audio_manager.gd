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

# Cached audio streams
var _ding_stream: AudioStreamWAV
var _buzz_stream: AudioStreamWAV

func _ready() -> void:
	try:
		# Get audio bus indices
		master_bus_idx = AudioServer.get_bus_index("Master")
		music_bus_idx = AudioServer.get_bus_index("Music") if AudioServer.get_bus_index("Music") != -1 else master_bus_idx
		sfx_bus_idx = AudioServer.get_bus_index("SFX") if AudioServer.get_bus_index("SFX") != -1 else master_bus_idx
		
		# Pre-generate procedural sounds
		_generate_cached_sounds()
		
		# Load audio settings from config
		load_audio_settings()
	except:
		print("WARNING: AudioManager initialization failed, using defaults")
		master_bus_idx = 0
		music_bus_idx = 0
		sfx_bus_idx = 0
		master_volume = 1.0
		music_volume = 1.0
		sfx_volume = 1.0
		enable_sound = true

## Load audio settings from configuration
func load_audio_settings() -> void:
	try:
		if ConfigFileHandler:
			master_volume = ConfigFileHandler.load_setting("audio", "master_volume", 1.0)
			music_volume = ConfigFileHandler.load_setting("audio", "music_volume", 1.0)
			sfx_volume = ConfigFileHandler.load_setting("audio", "sfx_volume", 1.0)
			enable_sound = ConfigFileHandler.load_setting("audio", "enable_sound", true)
		apply_volume_settings()
	except:
		print("WARNING: Failed to load audio settings, using defaults")
		master_volume = 1.0
		music_volume = 1.0
		sfx_volume = 1.0
		enable_sound = true
		apply_volume_settings()

## Apply current volume settings to audio buses
func apply_volume_settings() -> void:
	try:
		if master_bus_idx < 0:
			return  # Audio buses not available
		
		if not enable_sound:
			AudioServer.set_bus_mute(master_bus_idx, true)
			return
		
		AudioServer.set_bus_mute(master_bus_idx, false)
		if master_bus_idx >= 0:
			AudioServer.set_bus_volume_db(master_bus_idx, linear2db(master_volume))
		if music_bus_idx >= 0:
			AudioServer.set_bus_volume_db(music_bus_idx, linear2db(master_volume * music_volume))
		if sfx_bus_idx >= 0:
			AudioServer.set_bus_volume_db(sfx_bus_idx, linear2db(master_volume * sfx_volume))
	except:
		print("WARNING: Failed to apply volume settings, audio buses may not be configured")

## Set master volume (0.0 - 1.0)
func set_master_volume(volume: float) -> void:
	try:
		master_volume = clamp(volume, 0.0, 1.0)
		if ConfigFileHandler:
			ConfigFileHandler.save_setting("audio", "master_volume", master_volume)
		apply_volume_settings()
	except:
		print("WARNING: set_master_volume failed, using default master_volume = 1.0")
		master_volume = 1.0

## Set music volume (0.0 - 1.0)
func set_music_volume(volume: float) -> void:
	try:
		music_volume = clamp(volume, 0.0, 1.0)
		if ConfigFileHandler:
			ConfigFileHandler.save_setting("audio", "music_volume", music_volume)
		apply_volume_settings()
	except:
		print("WARNING: set_music_volume failed, using default music_volume = 1.0")
		music_volume = 1.0

## Set SFX volume (0.0 - 1.0)
func set_sfx_volume(volume: float) -> void:
	try:
		sfx_volume = clamp(volume, 0.0, 1.0)
		if ConfigFileHandler:
			ConfigFileHandler.save_setting("audio", "sfx_volume", sfx_volume)
		apply_volume_settings()
	except:
		print("WARNING: set_sfx_volume failed, using default sfx_volume = 1.0")
		sfx_volume = 1.0

## Toggle sound on/off
func set_sound_enabled(enabled: bool) -> void:
	try:
		enable_sound = enabled
		if ConfigFileHandler:
			ConfigFileHandler.save_setting("audio", "enable_sound", enabled)
		apply_volume_settings()
	except:
		print("WARNING: set_sound_enabled failed, using default enable_sound = true")
		enable_sound = true

## Play procedural "ding" sound for correct answer
func play_correct_sound() -> void:
	try:
		if not enable_sound or not _ding_stream:
			return
		_play_stream(_ding_stream)
	except:
		print("WARNING: play_correct_sound failed, audio playback skipped")

## Play procedural "buzz" sound for wrong answer
func play_wrong_sound() -> void:
	try:
		if not enable_sound or not _buzz_stream:
			return
		_play_stream(_buzz_stream)
	except:
		print("WARNING: play_wrong_sound failed, audio playback skipped")

## Helper to play a stream and cleanup
func _play_stream(stream: AudioStream) -> void:
	try:
		if not stream:
			print("WARNING: _play_stream received null stream")
			return
		
		var player = AudioStreamPlayer.new()
		if not player:
			print("WARNING: Failed to create AudioStreamPlayer")
			return
		
		add_child(player)
		player.bus = "SFX"
		player.stream = stream
		player.play()
		await player.finished
		player.queue_free()
	except:
		print("WARNING: _play_stream failed, audio playback skipped")

## Generate cached sounds once at startup
func _generate_cached_sounds() -> void:
	try:
		_ding_stream = _create_wav_stream(800.0, 1200.0, 0.2, 0.3, false)
		_buzz_stream = _create_wav_stream(150.0, 150.0, 0.3, 0.25, true)
		
		if not _ding_stream or not _buzz_stream:
			print("WARNING: Failed to generate cached sounds, using silence fallback")
	except:
		print("WARNING: _generate_cached_sounds failed, proceeding with silence fallback")
		_ding_stream = null
		_buzz_stream = null

## Create a WAV stream programmatically
func _create_wav_stream(freq_start: float, freq_end: float, duration: float, volume: float, is_buzz: bool) -> AudioStreamWAV:
	try:
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
		buffer.resize(sample_count * 2) # 2 bytes per sample (16-bit)
		
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
		
		stream.data = buffer
		return stream
	except:
		print("WARNING: _create_wav_stream failed, returning null")
		return null

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
