extends Control


@export_file var lobby_scene_path: String

var player_name: String

@onready var lobby_scene := load(lobby_scene_path)

@onready var message_label = $ScrollContainer/CenterContainer/VBoxContainer/MessageLabel as Label

@onready var name_edit := $ScrollContainer/CenterContainer/VBoxContainer/NameEdit as LineEdit
@onready var port_edit := $ScrollContainer/CenterContainer/VBoxContainer/PortEdit as LineEdit

@onready var ip_addr_edit := $ScrollContainer/CenterContainer/VBoxContainer/AdvancedContainer/IpAddrEdit as LineEdit
@onready var max_players_edit := $ScrollContainer/CenterContainer/VBoxContainer/AdvancedContainer/MaxPlayersEdit as LineEdit


func _on_ok_pressed():
	message_label.set_visible(false)
	
	# Paranoia
	multiplayer.get_multiplayer_peer().close()
	
	var peer = ENetMultiplayerPeer.new()
	
	# All sanitization should go here
	var port := _get_port()
	var ip_address := _get_ip_addr()
	var max_players := _get_max_players()
	player_name = _get_player_name()
	
	if not ip_address.is_empty():
		peer.set_bind_ip(ip_address)
	
	var result := peer.create_server(port, max_players)
	
	if result == ERR_CANT_CREATE:
		message_label.set_text("Could not create the server. Please check if port " + str(port) + " is available.")
		message_label.set_visible(true)
		return
	
	multiplayer.set_multiplayer_peer(peer)
	
	_go_to_lobby()


func _get_player_name() -> String:
	var name := name_edit.get_text()
	return name


func _get_port() -> int:
	var port := int(port_edit.get_text())
	return port


func _get_ip_addr() -> String:
	var ip_address := ip_addr_edit.get_text()
	return ip_address


func _get_max_players() -> int:
	# Subtracting 1 to account for the host which seems more intuitive
	var max_players := int(max_players_edit.get_text()) - 1
	return max_players


func _go_to_lobby():
	var player_id := multiplayer.get_unique_id()
	var player := Player.new(player_id, player_name)
	
	var lobby := lobby_scene.instantiate() as Lobby
	lobby.set_player(player)
	
	var root := $/root
	root.remove_child(self)
	root.add_child(lobby)
	queue_free()
