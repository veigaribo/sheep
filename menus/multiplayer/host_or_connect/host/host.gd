extends Control


@export_file var lobby_scene_path: String

var data = {}

@onready var message_label = $ScrollContainer/CenterContainer/VBoxContainer/MessageLabel as Label

@onready var name_edit := $ScrollContainer/CenterContainer/VBoxContainer/NameEdit as LineEdit
@onready var color_edit := $ScrollContainer/CenterContainer/VBoxContainer/ColorSelector as ColorSelector
@onready var port_edit := $ScrollContainer/CenterContainer/VBoxContainer/PortEdit as LineEdit
@onready var max_players_edit := $ScrollContainer/CenterContainer/VBoxContainer/MaxPlayersEdit as LineEdit

@onready var ip_addr_edit := $ScrollContainer/CenterContainer/VBoxContainer/AdvancedContainer/IpAddrEdit as LineEdit


func _ready():
	_load_defaults()


func _load_defaults():
	config.load()
	
	var default_name = config.get_default_multiplayer_name()
	var default_color = config.get_default_multiplayer_color()
	var default_port = config.get_default_multiplayer_host_port()
	var default_max_players = config.get_default_multiplayer_host_max_players()
	var default_ip_addr = config.get_default_multiplayer_host_ip_addr()
	
	if default_name != null:
		name_edit.set_text(default_name)
	if default_color != null:
		color_edit.set_pick_color(default_color)
	if default_port != null:
		port_edit.set_text(str(default_port))
	if default_max_players != null:
		max_players_edit.set_text(str(default_max_players))
	if default_ip_addr != null:
		ip_addr_edit.set_text(default_ip_addr)


func _persist_defaults():
	config.set_default_multiplayer_name(data['name'])
	config.set_default_multiplayer_color(data['color'])
	config.set_default_multiplayer_host_port(data['port'])
	config.set_default_multiplayer_host_max_players(data['max_players'])
	config.set_default_multiplayer_host_ip_addr(data['ip_address'])
	config.persist()


func _on_ok_pressed():
	_clear_message()
	
	# Paranoia
	multiplayer.get_multiplayer_peer().close()
	
	var color = _get_color()
	var port = _get_port()
	var max_players = _get_max_players()
	var ip_address = _get_ip_addr()
	var maybe_player_name = _get_player_name()
	
	if null in [port, max_players, ip_address, maybe_player_name]:
		return
	
	data = {
		'name': maybe_player_name,
		'color': color,
		'port': port,
		'max_players': max_players,
		'ip_address': ip_address,
	}
	
	_persist_defaults()
	
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


func _get_color():
	return color_edit.get_pick_color()


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
	
	var player := Player.new(player_id, data['name'], data['color'])
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
	if multiplayer != null:
		multiplayer.get_multiplayer_peer().close()
