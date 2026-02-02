extends Control

# Immediately transition to difficulty menu
func _ready() -> void:
	# Check if we have energy to play (if enabled)
	if FeatureConfig.energy_system_enabled:
		EnergySystem.current_energy = 100  # Ensure full energy
	
	# Immediately proceed to difficulty selection
	call_deferred("_proceed_to_difficulty")

func _proceed_to_difficulty() -> void:
	# Proceed to difficulty selection
	get_tree().change_scene_to_file("res://scenes/difficulty_menu.tscn")
