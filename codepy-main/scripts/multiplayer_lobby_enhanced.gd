extends Control

## LAN Multiplayer Lobby Enhancement
## Shows host indicator with crown icon
## Displays player list and connection status

@onready var host_label = $VBoxContainer/HostLabel
@onready var players_list = $VBoxContainer/PlayersList
@onready var status_label = $VBoxContainer/StatusLabel

var is_host: bool = false
var players: Array = []
var my_peer_id: int = 0

func _ready() -> void:
	if multiplayer:
		multiplayer.peer_connected.connect(_on_player_connected)
		multiplayer.peer_disconnected.connect(_on_player_disconnected)
	
	_update_host_status()
	_refresh_player_list()

func _on_player_connected(peer_id: int) -> void:
	_refresh_player_list()
	_update_status("Player %d joined!" % peer_id)

func _on_player_disconnected(peer_id: int) -> void:
	_refresh_player_list()
	_update_status("Player %d left." % peer_id)

func _update_host_status() -> void:
	if not host_label:
		return
	
	if multiplayer.is_server():
		is_host = true
		host_label.text = "👑 YOU ARE HOST"
		host_label.modulate = Color.YELLOW
	else:
		is_host = false
		host_label.text = "Waiting for host..."
		host_label.modulate = Color.WHITE

func _refresh_player_list() -> void:
	if not players_list:
		return
	
	players_list.clear()
	players = []
	
	if multiplayer:
		# Add server/host
		var host_text = "👑 Host (Server)"
		players_list.add_item(host_text)
		players.append({"id": 1, "name": "Host", "is_host": true})
		
		# Add other players
		for peer_id in multiplayer.get_peers():
			var player_text = "🎮 Player %d" % peer_id
			players_list.add_item(player_text)
			players.append({"id": peer_id, "name": "Player %d" % peer_id, "is_host": false})

func _update_status(message: String) -> void:
	if status_label:
		status_label.text = message

func get_host_info() -> Dictionary:
	return {
		"is_host": is_host,
		"host_indicator": "👑" if is_host else "",
		"player_count": players.size()
	}
