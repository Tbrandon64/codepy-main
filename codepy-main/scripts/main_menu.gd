extends Control

# Networking variables
var enet_peer: ENetMultiplayerPeer
var server_port: int = 12345
var server_ip: String = ""
var is_host: bool = false
var is_connecting: bool = false

func _ready() -> void:
	# Connect button signals
	$VBoxContainer/SinglePlayerBtn.pressed.connect(_on_single_player_pressed)
	$VBoxContainer/HostBtn.pressed.connect(_on_host_pressed)
	$VBoxContainer/JoinBtn.pressed.connect(_on_join_pressed)
	if FeatureConfig.adventure_mode_enabled:
		$VBoxContainer/AdventureBtn.pressed.connect(_on_adventure_pressed)
	if FeatureConfig.teacher_portal_enabled:
		$VBoxContainer/TeacherPortalBtn.pressed.connect(_on_teacher_portal_pressed)
	$VBoxContainer/QuitBtn.pressed.connect(_on_quit_pressed)
	
	# Connect dialog signals
	$PortDialog.confirmed.connect(_on_port_dialog_confirmed)
	$IPPortDialog.confirmed.connect(_on_ip_port_dialog_confirmed)
	
	# Connect multiplayer signals
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	
	# Style buttons with proper colors and fonts
	_setup_button_styles()

func _setup_button_styles() -> void:
	var font = load("res://assets/fonts/arial_bold.tres")
	var font_size = 28
	
	# Single Player - Blue
	var single_btn = $VBoxContainer/SinglePlayerBtn
	_style_button(single_btn, Color(0, 0.4, 1, 1), font, font_size)
	
	# Adventure - Purple
	if FeatureConfig.adventure_mode_enabled:
		var adventure_btn = $VBoxContainer/AdventureBtn
		_style_button(adventure_btn, Color(0.8, 0, 0.8, 1), font, font_size)
	
	# Host - Green
	var host_btn = $VBoxContainer/HostBtn
	_style_button(host_btn, Color(0, 1, 0, 1), font, font_size)
	
	# Join - Orange
	var join_btn = $VBoxContainer/JoinBtn
	_style_button(join_btn, Color(1, 0.65, 0, 1), font, font_size)
	
	# Teacher Portal - Red/Dark Red
	if FeatureConfig.teacher_portal_enabled:
		var teacher_btn = $VBoxContainer/TeacherPortalBtn
		_style_button(teacher_btn, Color(0.7, 0, 0, 1), font, 20)
	
	# Quit - Red
	var quit_btn = $VBoxContainer/QuitBtn
	_style_button(quit_btn, Color(1, 0, 0, 1), font, font_size)

func _style_button(button: Button, color: Color, font: Font, font_size: int) -> void:
	var style = StyleBoxFlat.new()
	style.bg_color = color
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = color.lightened(0.3)
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_right = 4
	style.corner_radius_bottom_left = 4
	
	button.add_theme_stylebox_override("normal", style)
	button.add_theme_stylebox_override("hover", style.duplicate())
	button.add_theme_font_override("font", font)
	button.add_theme_font_size_override("font_size", font_size)
	button.add_theme_color_override("font_color", Color.WHITE)

func _on_single_player_pressed() -> void:
	# Load single player scene
	get_tree().change_scene_to_file("res://scenes/single_player.tscn")

func _on_adventure_pressed() -> void:
	# Start adventure mode
	if FeatureConfig.energy_system_enabled:
		# Initialize adventure if needed
		AdventureManager.start_adventure()
	get_tree().change_scene_to_file("res://scenes/adventure_map.tscn")

func _on_teacher_portal_pressed() -> void:
	# Load teacher portal
	get_tree().change_scene_to_file("res://scenes/teacher_portal.tscn")

func _on_host_pressed() -> void:
	# Show port input dialog
	$PortDialog.get_ok_button().text = "Host"
	$PortDialog.popup_centered()

func _on_join_pressed() -> void:
	# Show IP/Port input dialog
	$IPPortDialog.popup_centered()

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_port_dialog_confirmed() -> void:
	var port_text = $PortDialog/PortInput.text
	
	if port_text.is_empty():
		server_port = 12345
	else:
		server_port = int(port_text)
	
	# Start ENet server
	_start_enet_server()

func _start_enet_server() -> void:
	enet_peer = ENetMultiplayerPeer.new()
	var error = enet_peer.create_server(server_port, 2)
	
	if error != OK:
		_show_error("Failed to start server on port %d" % server_port)
		return
	
	multiplayer.multiplayer_peer = enet_peer
	is_host = true
	is_connecting = true
	
	# Get local IP
	server_ip = _get_local_ip()
	
	# Show info popup with IP:Port
	_show_server_info(server_ip, server_port)

func _get_local_ip() -> String:
	# Try to get local IP from environment or use localhost
	var hostname = OS.get_environment("HOSTNAME")
	if hostname.is_empty():
		return "localhost"
	
	# For better IP detection, you might want to use a networking library
	# For now, returning a placeholder - users should know their IP
	return "127.0.0.1"

func _show_server_info(ip: String, port: int) -> void:
	var info_label = $InfoPopup/InfoLabel
	info_label.text = "Server running at:\n%s:%d\n\nWaiting for player..." % [ip, port]
	$InfoPopup.popup_centered()

func _on_ip_port_dialog_confirmed() -> void:
	var ip = $IPPortDialog/IPInput.text
	var port_text = $IPPortDialog/PortInput2.text
	var port = 12345
	
	if ip.is_empty():
		_show_error("Please enter a server IP")
		return
	
	if not port_text.is_empty():
		port = int(port_text)
	
	# Start ENet client
	_connect_enet_client(ip, port)

func _connect_enet_client(ip: String, port: int) -> void:
	enet_peer = ENetMultiplayerPeer.new()
	var error = enet_peer.create_client(ip, port)
	
	if error != OK:
		_show_error("Failed to create client connection")
		return
	
	multiplayer.multiplayer_peer = enet_peer
	is_connecting = true

func _show_error(message: String) -> void:
	var dialog = AcceptDialog.new()
	dialog.title = "Error"
	dialog.dialog_text = message
	add_child(dialog)
	dialog.popup_centered_ratio(0.6)

# ============ MULTIPLAYER CONNECTION HANDLERS ============

func _on_connected_to_server() -> void:
	# Client successfully connected to server
	print("Connected to server!")
	is_connecting = false
	
	# Close any dialogs and proceed to difficulty menu
	if $InfoPopup.visible:
		$InfoPopup.hide()
	
	await get_tree().process_frame
	get_tree().change_scene_to_file("res://scenes/difficulty_menu.tscn")

func _on_connection_failed() -> void:
	# Client connection attempt failed
	is_connecting = false
	_show_error("Failed to connect to server. Check IP and port.")
	multiplayer.multiplayer_peer = null

func _on_server_disconnected() -> void:
	# Client was disconnected from server
	_show_connection_lost()
	multiplayer.multiplayer_peer = null

func _on_peer_connected(peer_id: int) -> void:
	# A peer connected to the server
	print("Peer %d connected" % peer_id)
	
	# If this is the host and we have a second peer, proceed to difficulty menu
	if is_host and is_connecting:
		is_connecting = false
		if $InfoPopup.visible:
			$InfoPopup.hide()
		
		await get_tree().process_frame
		get_tree().change_scene_to_file("res://scenes/difficulty_menu.tscn")

func _on_peer_disconnected(peer_id: int) -> void:
	# A peer disconnected from the server
	print("Peer %d disconnected" % peer_id)
	
	# If we're in a game, show connection lost and return to menu
	if get_tree().current_scene.name != "MainMenu":
		_show_connection_lost()

func _show_connection_lost() -> void:
	# Reset networking
	multiplayer.multiplayer_peer = null
	is_host = false
	is_connecting = false
	
	var dialog = AcceptDialog.new()
	dialog.title = "Connection Lost"
	dialog.dialog_text = "Lost connection to the other player.\n\nReturning to main menu..."
	add_child(dialog)
	dialog.confirmed.connect(func(): 
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	)
	dialog.popup_centered_ratio(0.6)
