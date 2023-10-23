extends Control


@export_file var lobby_scene_path: String

var player_name: String

@onready var lobby_scene := load(lobby_scene_path)

@onready var message_label = $ScrollContainer/CenterContainer/VBoxContainer/MessageLabel as Label

@onready var name_edit := $ScrollContainer/CenterContainer/VBoxContainer/NameEdit as LineEdit
@onready var port_edit := $ScrollContainer/CenterContainer/VBoxContainer/PortEdit as LineEdit
@onready var max_players_edit := $ScrollContainer/CenterContainer/VBoxContainer/MaxPlayersEdit as LineEdit

@onready var ip_addr_edit := $ScrollContainer/CenterContainer/VBoxContainer/AdvancedContainer/IpAddrEdit as LineEdit


func _on_ok_pressed():
	_clear_message()
	
	# Paranoia
	multiplayer.get_multiplayer_peer().close()
	
	var port = _get_port()
	var max_players = _get_max_players()
	var ip_address = _get_ip_addr()
	var maybe_player_name = _get_player_name()
	
	if null in [port, max_players, ip_address, maybe_player_name]:
		return
	
	player_name = maybe_player_name as String
	
	var peer = ENetMultiplayerPeer.new()
	peer.set_bind_ip(ip_address)
	
	# Subtracting 1 to account for the server, which is a player, but not a client
	var result := peer.create_server(port, max_players - 1)
	
	if result == ERR_CANT_CREATE:
		_display_message("Could not create the server. Please check if port " + str(port) + " is available.")
		return
	
	multiplayer.set_multiplayer_peer(peer)
	_go_to_lobby()


func _get_player_name():
	var name := name_edit.get_text().strip_edges()
	
	if name.length() == 0:
		_display_message("Name should not be empty.")
		return null
	
	if name.length() > 20:
		_display_message("Please keep name at most 20 characters long.")
		return null
	
	return name


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


func _get_max_players():
	var s_max_players = max_players_edit.get_text().strip_edges()
	
	if not s_max_players.is_valid_int():
		_display_message("Max players should be a whole number.")
		return null
	
	var max_players := int(s_max_players)
	
	if max_players <= 0:
		_display_message("A game must contain at least 1 player.")
		return null
	
	# A value of 1 logs an error but apparently works fine
	
	if max_players > 4095:
		_display_message("A game must contain at most 4095 players, unfortunately.")
		return null
	
	return max_players


func _get_ip_addr():
	var ip_address := ip_addr_edit.get_text().strip_edges()
	
	if ip_address.is_empty():
		return "*"
	
	if not ip_address.is_valid_ip_address():
		_display_message("IP address should be a valid IP address.")
		return null
	
	return ip_address


func _go_to_lobby():
	var player_id := multiplayer.get_unique_id()
	var player := Player.new(player_id, player_name)
	multiplayer_data.self_player = player
	
	get_tree().change_scene_to_file(lobby_scene_path)


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
	# Paranoia
	multiplayer.get_multiplayer_peer().close()
