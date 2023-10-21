extends Control


@export_file var lobby_scene_path: String

var player_name: String

@onready var lobby_scene := load(lobby_scene_path)
@onready var name_edit := $CenterContainer/VBoxContainer/NameEdit as LineEdit
@onready var ip_addr_edit := $CenterContainer/VBoxContainer/IpAddrEdit as LineEdit
@onready var port_edit := $CenterContainer/VBoxContainer/PortEdit as LineEdit


func _ready():
	multiplayer.connected_to_server.connect(_on_connected)
	multiplayer.connection_failed.connect(_on_not_connected)


func _on_ok_pressed():
	var peer = ENetMultiplayerPeer.new()
	
	# All sanitization should go here
	var ip_address := _get_ip_addr()
	var port := _get_port()
	player_name = _get_player_name()
	
	peer.create_client(ip_address, port)
	multiplayer.set_multiplayer_peer(peer)


func _get_ip_addr() -> String:
	var ip_address := ip_addr_edit.get_text()
	return ip_address


func _get_port() -> int:
	var port := int(port_edit.get_text())
	return port


func _get_player_name() -> String:
	var name := name_edit.get_text()
	return name


func _go_to_lobby(player_id: int):
	var lobby := lobby_scene.instantiate() as Lobby
	var player := Player.new(player_id, player_name)
	lobby.set_player(player)
	
	var root := $/root
	root.remove_child(self)
	root.add_child(lobby)
	queue_free()


func _on_connected():
	var id := multiplayer.get_unique_id()
	_go_to_lobby(id)


func _on_not_connected():
	# TODO
	print("pau")
