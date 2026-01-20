extends Control

# Check energy before loading difficulty menu
func _ready() -> void:
	$BackButton.pressed.connect(_on_back_pressed)
	
	# Check if we have energy to play (if enabled)
	if FeatureConfig.energy_system_enabled:
		if EnergySystem.get_current_energy() < 10:
			_show_low_energy_warning()

## Show low energy warning
func _show_low_energy_warning() -> void:
	var dialog = AcceptDialog.new()
	dialog.title = "Low Energy"
	dialog.dialog_text = "You have very little energy left. Would you like to wait for it to regenerate?\n\nCurrent Energy: %d/%d" % [EnergySystem.get_current_energy(), EnergySystem.get_max_energy()]
	add_child(dialog)
	dialog.popup_centered()

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
