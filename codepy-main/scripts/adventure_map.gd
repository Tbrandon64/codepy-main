extends Control

## Adventure Map - Minecraft Dungeons style map display and navigation

@onready var canvas: Control = $Canvas
@onready var ui_container: VBoxContainer = $HeaderArea/VBoxContainer
var dungeon_buttons: Dictionary = {}
var selected_dungeon: int = -1
var dungeon_scene_path: String = "res://scenes/adventure_level.tscn"

# Visual properties
const DUNGEON_BUTTON_SIZE: Vector2 = Vector2(80, 80)
const DUNGEON_BUTTON_SCALE: float = 0.15
const LINE_COLOR: Color = Color.WHITE
const CLEARED_COLOR: Color = Color.GREEN
const LOCKED_COLOR: Color = Color.GRAY
const AVAILABLE_COLOR: Color = Color.YELLOW
const PATH_WIDTH: float = 3.0
const HEADER_AREA_HEIGHT: float = 200.0

func _ready() -> void:
	_setup_ui()
	AdventureManager.map_updated.connect(_on_map_updated)
	_draw_dungeon_map()

## Setup the UI elements
func _setup_ui() -> void:
	ui_container.add_theme_constant_override("separation", 8)

	# Add header
	var header = Label.new()
	header.text = "Adventure Map - Level %d" % AdventureManager.get_adventure_level()
	header.add_theme_font_size_override("font_size", 32)
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ui_container.add_child(header)
	
	# Add experience bar
	var exp_container = HBoxContainer.new()
	exp_container.add_theme_constant_override("separation", 12)
	exp_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var exp_label = Label.new()
	var progress = AdventureManager.get_experience_progress()
	exp_label.text = "Experience: %d / %d" % [progress["current"], progress["required"]]
	exp_label.custom_minimum_size = Vector2(160, 0)
	var exp_bar = ProgressBar.new()
	exp_bar.value = progress["percentage"] * 100
	exp_bar.custom_minimum_size = Vector2(0, 20)
	exp_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	exp_container.add_child(exp_label)
	exp_container.add_child(exp_bar)
	ui_container.add_child(exp_container)
	
	# Add energy display
	if FeatureConfig.energy_system_enabled:
		var energy_label = Label.new()
		energy_label.text = "Energy: %d / %d" % [EnergySystem.get_current_energy(), EnergySystem.get_max_energy()]
		energy_label.add_theme_font_size_override("font_size", 18)
		energy_label.add_theme_color_override("font_color", Color.YELLOW)
		energy_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		energy_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		ui_container.add_child(energy_label)
		EnergySystem.energy_changed.connect(func(energy): energy_label.text = "Energy: %d / %d" % [energy, EnergySystem.get_max_energy()])
	
	# Add back button
	var back_button = Button.new()
	back_button.text = "Back to Menu"
	back_button.custom_minimum_size = Vector2(180, 40)
	back_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	back_button.pressed.connect(_on_back_pressed)
	ui_container.add_child(back_button)

## Draw the dungeon map
func _draw_dungeon_map() -> void:
	dungeon_buttons.clear()
	for child in canvas.get_children():
		child.queue_free()
	
	var dungeons = AdventureManager.get_current_map_dungeons()
	var map_offset = _get_map_offset(dungeons)
	
	# Draw connections between dungeons
	_draw_path(dungeons, map_offset)
	
	# Create buttons for each dungeon
	for dungeon in dungeons:
		var button = Button.new()
		button.custom_minimum_size = DUNGEON_BUTTON_SIZE
		button.position = dungeon.position + map_offset
		
		# Set button appearance based on state
		_update_dungeon_button_appearance(button, dungeon)
		
		# Set button text
		button.text = "%s\nLv%d" % [dungeon.difficulty.to_upper()[0], dungeon.level]
		
		# Connect button
		button.pressed.connect(func(): _on_dungeon_selected(dungeon.id))
		
		canvas.add_child(button)
		dungeon_buttons[dungeon.id] = button

func _get_map_offset(dungeons) -> Vector2:
	if dungeons.is_empty():
		return Vector2.ZERO

	var bounds = Rect2(dungeons[0].position, DUNGEON_BUTTON_SIZE)
	for dungeon in dungeons:
		bounds = bounds.expand(dungeon.position + DUNGEON_BUTTON_SIZE)

	var viewport_size = get_viewport_rect().size
	var map_area_size = Vector2(viewport_size.x, maxf(viewport_size.y - HEADER_AREA_HEIGHT, 0.0))
	var map_area_origin = Vector2(0, HEADER_AREA_HEIGHT)
	return map_area_origin + (map_area_size - bounds.size) / 2.0 - bounds.position

## Update dungeon button appearance
func _update_dungeon_button_appearance(button: Button, dungeon) -> void:
	var style = StyleBoxFlat.new()
	
	if dungeon.cleared:
		# Cleared - Green with checkmark aesthetic
		style.bg_color = CLEARED_COLOR
		button.text = dungeon.text + "\n✓"
	elif AdventureManager.can_enter_dungeon(dungeon.id):
		# Available - Yellow
		style.bg_color = AVAILABLE_COLOR
		button.add_theme_color_override("font_color", Color.BLACK)
	else:
		# Locked - Gray
		style.bg_color = LOCKED_COLOR
		button.disabled = true
	
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = style.bg_color.lightened(0.5)
	button.add_theme_stylebox_override("normal", style)

## Draw path connecting dungeons
func _draw_path(dungeons, map_offset: Vector2) -> void:
	var path_drawer = ColorRect.new()
	path_drawer.name = "PathDrawer"
	canvas.add_child(path_drawer)
	_on_path_redraw(dungeons, map_offset)

## Draw the actual path connections
func _on_path_redraw(dungeons, map_offset: Vector2) -> void:
	if dungeons.size() > 1:
		for i in range(dungeons.size() - 1):
			var start = dungeons[i].position + DUNGEON_BUTTON_SIZE / 2 + map_offset
			var end = dungeons[i + 1].position + DUNGEON_BUTTON_SIZE / 2 + map_offset
			_draw_line(start, end, LINE_COLOR, PATH_WIDTH)

## Helper to draw a line
func _draw_line(start: Vector2, end: Vector2, color: Color, width: float) -> void:
	var line = Line2D.new()
	line.add_point(start)
	line.add_point(end)
	line.width = width
	line.default_color = color
	canvas.add_child(line)

## Handle dungeon selection
func _on_dungeon_selected(dungeon_id: int) -> void:
	if not AdventureManager.can_enter_dungeon(dungeon_id):
		return
	
	selected_dungeon = dungeon_id
	
	# Consume energy and load the adventure level scene
	if AdventureManager.enter_dungeon(dungeon_id):
		# Load the adventure level with the dungeon data
		get_tree().change_scene_to_file(dungeon_scene_path)
	else:
		var dialog = AcceptDialog.new()
		dialog.title = "Cannot Enter"
		dialog.dialog_text = "Not enough energy to enter this dungeon!"
		add_child(dialog)
		dialog.popup_centered()

## Handle back button
func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

## Handle map updates from AdventureManager
func _on_map_updated() -> void:
	_draw_dungeon_map()
