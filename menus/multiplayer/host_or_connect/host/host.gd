extends Control


@export_file var lobby_scene_path: String

var player_name: String

@onready var lobby_scene := load(lobby_scene_path)
@onready var name_edit := $ScrollContainer/CenterContainer/VBoxContainer/NameEdit as LineEdit
@onready var port_edit := $ScrollContainer/CenterContainer/VBoxContainer/PortEdit as LineEdit

@onready var ip_addr_edit := $ScrollContainer/CenterContainer/VBoxContainer/AdvancedContainer/IpAddrEdit as LineEdit
@onready var max_players_edit := $ScrollContainer/CenterContainer/VBoxContainer/AdvancedContainer/MaxPlayersEdit as LineEdit


func _on_ok_pressed():
	var peer = ENetMultiplayerPeer.new()
	
	# All sanitization should go here
	var port := _get_port()
	var ip_address := _get_ip_addr()
	var max_players := _get_max_players()
	player_name = _get_player_name()
	
	if not ip_address.is_empty():
		peer.set_bind_ip(ip_address)
	
	peer.create_server(port, max_players)
	multiplayer.set_multiplayer_peer(peer)
	
	_go_to_lobby(1)


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
	var max_players := int(max_players_edit.get_text())
	return max_players


func _go_to_lobby(player_id: int):
	var lobby := lobby_scene.instantiate() as Lobby
	var player := Player.new(player_id, player_name)
	lobby.set_player(player)
	
	var root := $/root
	root.remove_child(self)
	root.add_child(lobby)
	queue_free()
