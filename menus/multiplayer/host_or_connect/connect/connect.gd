extends Control


@export_file var lobby_scene_path: String

var player_name: String

@onready var lobby_scene := load(lobby_scene_path)

@onready var message_label = $ScrollContainer/CenterContainer/VBoxContainer/MessageLabel as Label

@onready var name_edit := $ScrollContainer/CenterContainer/VBoxContainer/NameEdit as LineEdit
@onready var ip_addr_edit := $ScrollContainer/CenterContainer/VBoxContainer/AddrEdit as LineEdit
@onready var port_edit := $ScrollContainer/CenterContainer/VBoxContainer/PortEdit as LineEdit


func _ready():
	multiplayer.connected_to_server.connect(_on_connected)
	multiplayer.connection_failed.connect(_on_not_connected)


func _on_ok_pressed():
	_clear_message()
	
	# Close any possible hanging attempted connections
	multiplayer.get_multiplayer_peer().close()
	
	# All sanitization should go here
	var address = _get_addr()
	var port = _get_port()
	var maybe_player_name = _get_player_name()
	
	if null in [address, port, maybe_player_name]:
		return
	
	player_name = maybe_player_name
	
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(address, port)
	
	multiplayer.set_multiplayer_peer(peer)
	
	_display_message("Connecting...")


func _get_player_name():
	var name := name_edit.get_text().strip_edges()
	
	if name.length() == 0:
		_display_message("Name should not be empty.")
		return null
	
	if name.length() > 20:
		_display_message("Please keep name at most 20 characters long.")
		return null
	
	return name


func _get_addr():
	var address := ip_addr_edit.get_text().strip_edges()
	
	if address.length() == 0:
		_display_message("Address should not be empty.")
		return null
	
	if address.length() > 253:
		_display_message("Address length should not exceed 253.")
		return null
	
	return address


func _get_port():
	var s_port := port_edit.get_text().strip_edges()
	
	if not s_port.is_valid_int():
		_display_message("Port should be a whole number.")
		return null
	
	var port = int(s_port)
	
	if port <= 0:
		_display_message("Port should be a positive number.")
		return null
	
	if port > 65535:
		_display_message("Port should not exceed 65535.")
		return null
	
	return port


func _go_to_lobby():
	get_tree().change_scene_to_file(lobby_scene_path)


func _on_connected():
	var player_id := multiplayer.get_unique_id()
	var player := Player.new(player_id, player_name)
	multiplayer_data.self_player = player
	
	_go_to_lobby()


func _on_not_connected():
	# Takes a while to happen
	_clear_message()
	_display_message("Could not connect.")


func _clear_message():
	message_label.set_visible(false)
	message_label.set_text("")


func _display_message(message: String):
	var current_text = message_label.get_text()
	
	if current_text.is_empty():
		message_label.set_text(message)
		message_label.set_visible(true)
	else:
		message_label.set_text(current_text + "\n" + message)
	
	return


func _on_return_pressed():
	# Close any possible hanging attempted connections
	multiplayer.get_multiplayer_peer().close()
