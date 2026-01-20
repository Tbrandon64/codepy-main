extends Control

## Teacher Portal - Intuitive dashboard for educators to manage classes and game settings
## Completely optional - enabled only in FeatureConfig

var is_authenticated: bool = false
var current_teacher_email: String = ""

# UI References (will be created dynamically)
var login_panel: PanelContainer
var dashboard_panel: PanelContainer
var settings_panel: PanelContainer

func _ready() -> void:
	if not FeatureConfig.teacher_portal_enabled:
		push_error("Teacher Portal is not enabled. Enable it in FeatureConfig.")
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
		return
	
	_create_login_panel()
	_show_login_panel()

## Create the login panel
func _create_login_panel() -> void:
	login_panel = PanelContainer.new()
	login_panel.add_theme_stylebox_override("panel", StyleBoxFlat.new())
	
	var login_container = VBoxContainer.new()
	
	# Title
	var title = Label.new()
	title.text = "🎓 Teacher Portal Login"
	title.add_theme_font_size_override("font_size", 32)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	login_container.add_child(title)
	
	# Instructions
	var instructions = Label.new()
	instructions.text = "Enter your teacher credentials to access class management"
	instructions.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	login_container.add_child(instructions)
	
	# Email input
	var email_label = Label.new()
	email_label.text = "Teacher Email:"
	login_container.add_child(email_label)
	
	var email_input = LineEdit.new()
	email_input.placeholder_text = "teacher@school.edu"
	email_input.custom_minimum_size = Vector2(300, 40)
	login_container.add_child(email_input)
	
	# Password input
	var password_label = Label.new()
	password_label.text = "Password:"
	login_container.add_child(password_label)
	
	var password_input = LineEdit.new()
	password_input.placeholder_text = "••••••••"
	password_input.secret = true
	password_input.custom_minimum_size = Vector2(300, 40)
	login_container.add_child(password_input)
	
	# Remember me checkbox
	var remember_check = CheckBox.new()
	remember_check.text = "Remember me"
	login_container.add_child(remember_check)
	
	# Login button
	var login_button = Button.new()
	login_button.text = "Login"
	login_button.custom_minimum_size = Vector2(300, 50)
	login_button.pressed.connect(func(): _attempt_login(email_input.text, password_input.text))
	login_container.add_child(login_button)
	
	# Back to menu
	var back_button = Button.new()
	back_button.text = "Back to Menu"
	back_button.custom_minimum_size = Vector2(300, 40)
	back_button.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/main_menu.tscn"))
	login_container.add_child(back_button)
	
	login_panel.add_child(login_container)
	add_child(login_panel)

## Attempt login
func _attempt_login(email: String, password: String) -> void:
	# Simple validation (in production, this would verify against a database)
	if email.is_empty() or password.is_empty():
		_show_error_dialog("Please enter both email and password")
		return
	
	if not email.contains("@"):
		_show_error_dialog("Please enter a valid email address")
		return
	
	if password.length() < 6:
		_show_error_dialog("Password must be at least 6 characters")
		return
	
	# Authentication successful (in production, verify credentials)
	is_authenticated = true
	current_teacher_email = email
	FeatureConfig.teacher_settings["teacher_name"] = email.split("@")[0]
	
	_hide_login_panel()
	_show_dashboard()

## Show error dialog
func _show_error_dialog(message: String) -> void:
	var dialog = AcceptDialog.new()
	dialog.title = "Error"
	dialog.dialog_text = message
	add_child(dialog)
	dialog.popup_centered()

## Hide login panel
func _hide_login_panel() -> void:
	if login_panel:
		login_panel.queue_free()

## Create and show dashboard
func _show_dashboard() -> void:
	dashboard_panel = PanelContainer.new()
	
	var main_container = VBoxContainer.new()
	
	# Header with teacher name
	var header = HBoxContainer.new()
	var welcome_label = Label.new()
	welcome_label.text = "Welcome, Teacher %s" % FeatureConfig.teacher_settings["teacher_name"]
	welcome_label.add_theme_font_size_override("font_size", 24)
	header.add_child(welcome_label)
	
	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(spacer)
	
	var logout_button = Button.new()
	logout_button.text = "Logout"
	logout_button.pressed.connect(_logout)
	header.add_child(logout_button)
	
	main_container.add_child(header)
	
	# Tab container for different sections
	var tab_container = TabContainer.new()
	
	# Classes Tab
	var classes_panel = _create_classes_panel()
	tab_container.add_child(classes_panel)
	tab_container.set_tab_title(0, "Classes")
	
	# Settings Tab
	var settings_panel = _create_settings_panel()
	tab_container.add_child(settings_panel)
	tab_container.set_tab_title(1, "Settings")
	
	# Analytics Tab
	var analytics_panel = _create_analytics_panel()
	tab_container.add_child(analytics_panel)
	tab_container.set_tab_title(2, "Analytics")
	
	main_container.add_child(tab_container)
	
	dashboard_panel.add_child(main_container)
	add_child(dashboard_panel)
	FeatureConfig.set_teacher_mode_active(true)

## Create classes management panel
func _create_classes_panel() -> PanelContainer:
	var panel = PanelContainer.new()
	var container = VBoxContainer.new()
	
	# Title
	var title = Label.new()
	title.text = "📚 My Classes"
	title.add_theme_font_size_override("font_size", 24)
	container.add_child(title)
	
	# Create new class button
	var create_button = Button.new()
	create_button.text = "+ Create New Class"
	create_button.custom_minimum_size = Vector2(200, 40)
	create_button.pressed.connect(_create_new_class)
	container.add_child(create_button)
	
	# Classes list (placeholder)
	var list_label = Label.new()
	list_label.text = "No classes created yet. Create one to get started!"
	container.add_child(list_label)
	
	# Class info template
	var sample_class = HBoxContainer.new()
	var class_name = Label.new()
	class_name.text = "📌 Class Name: Math 101"
	sample_class.add_child(class_name)
	
	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sample_class.add_child(spacer)
	
	var manage_btn = Button.new()
	manage_btn.text = "Manage"
	manage_btn.custom_minimum_size = Vector2(80, 30)
	sample_class.add_child(manage_btn)
	
	container.add_child(sample_class)
	panel.add_child(container)
	return panel

## Create settings panel
func _create_settings_panel() -> PanelContainer:
	var panel = PanelContainer.new()
	var container = VBoxContainer.new()
	
	# Title
	var title = Label.new()
	title.text = "⚙️ Game Settings"
	title.add_theme_font_size_override("font_size", 24)
	container.add_child(title)
	
	# Difficulty restrictions
	var diff_title = Label.new()
	diff_title.text = "Restrict Difficulty Levels:"
	container.add_child(diff_title)
	
	var easy_check = CheckBox.new()
	easy_check.text = "Allow Easy"
	easy_check.button_pressed = true
	container.add_child(easy_check)
	
	var medium_check = CheckBox.new()
	medium_check.text = "Allow Medium"
	medium_check.button_pressed = true
	container.add_child(medium_check)
	
	var hard_check = CheckBox.new()
	hard_check.text = "Allow Hard"
	hard_check.button_pressed = true
	container.add_child(hard_check)
	
	# Time limit multiplier
	var time_label = Label.new()
	time_label.text = "Time Limit Multiplier:"
	container.add_child(time_label)
	
	var time_slider = HSlider.new()
	time_slider.min_value = 0.5
	time_slider.max_value = 2.0
	time_slider.value = 1.0
	time_slider.step = 0.1
	time_slider.custom_minimum_size = Vector2(300, 30)
	container.add_child(time_slider)
	
	# Energy cost multiplier
	var energy_label = Label.new()
	energy_label.text = "Energy Cost Multiplier:"
	container.add_child(energy_label)
	
	var energy_slider = HSlider.new()
	energy_slider.min_value = 0.5
	energy_slider.max_value = 2.0
	energy_slider.value = 1.0
	energy_slider.step = 0.1
	energy_slider.custom_minimum_size = Vector2(300, 30)
	container.add_child(energy_slider)
	
	# Save button
	var save_button = Button.new()
	save_button.text = "Save Settings"
	save_button.pressed.connect(func(): _save_teacher_settings(
		[easy_check.button_pressed, medium_check.button_pressed, hard_check.button_pressed],
		time_slider.value,
		energy_slider.value
	))
	container.add_child(save_button)
	
	panel.add_child(container)
	return panel

## Create analytics panel
func _create_analytics_panel() -> PanelContainer:
	var panel = PanelContainer.new()
	var container = VBoxContainer.new()
	
	# Title
	var title = Label.new()
	title.text = "📊 Class Analytics"
	title.add_theme_font_size_override("font_size", 24)
	container.add_child(title)
	
	# Stats placeholders
	var stats_text = Label.new()
	stats_text.text = """
	📈 Statistics (requires students in class)
	
	Total Students: 0
	Average Score: 0
	Total Games Played: 0
	Average Time/Game: 0:00
	
	Top Performers:
	(No data yet)
	"""
	container.add_child(stats_text)
	
	panel.add_child(container)
	return panel

## Create new class dialog
func _create_new_class() -> void:
	var dialog = ConfirmationDialog.new()
	dialog.title = "Create New Class"
	
	var container = VBoxContainer.new()
	
	var name_label = Label.new()
	name_label.text = "Class Name:"
	container.add_child(name_label)
	
	var name_input = LineEdit.new()
	name_input.placeholder_text = "e.g., Math 101"
	container.add_child(name_input)
	
	dialog.add_child(container)
	dialog.confirmed.connect(func(): _on_class_created(name_input.text))
	add_child(dialog)
	dialog.popup_centered()

## Save teacher settings
func _save_teacher_settings(difficulties: Array, time_mult: float, energy_mult: float) -> void:
	var restrictions = []
	if not difficulties[0]:
		restrictions.append("easy")
	if not difficulties[1]:
		restrictions.append("medium")
	if not difficulties[2]:
		restrictions.append("hard")
	
	FeatureConfig.update_teacher_settings({
		"difficulty_restrictions": restrictions,
		"time_limit_multiplier": time_mult,
		"energy_cost_multiplier": energy_mult
	})
	
	_show_success_dialog("Settings saved successfully!")

## Handle class creation
func _on_class_created(class_name: String) -> void:
	if class_name.is_empty():
		_show_error_dialog("Please enter a class name")
		return
	
	_show_success_dialog("Class '%s' created successfully!" % class_name)

## Show success dialog
func _show_success_dialog(message: String) -> void:
	var dialog = AcceptDialog.new()
	dialog.title = "Success"
	dialog.dialog_text = message
	add_child(dialog)
	dialog.popup_centered()

## Logout
func _logout() -> void:
	is_authenticated = false
	current_teacher_email = ""
	FeatureConfig.set_teacher_mode_active(false)
	
	if dashboard_panel:
		dashboard_panel.queue_free()
	
	_create_login_panel()
	_show_login_panel()

## Show login panel
func _show_login_panel() -> void:
	if login_panel:
		login_panel.show()
