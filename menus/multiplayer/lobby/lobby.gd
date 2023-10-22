class_name Lobby
extends Control


@export_file var previous_scene_path: String
@export_file var main_scene_path: String
@export_file var player_name_scene_path: String

var players = {}

@onready var self_player: Player

@onready var previous_scene := load(previous_scene_path)
@onready var previous := previous_scene.instantiate() as Control

@onready var main_scene := load(main_scene_path)
@onready var main := main_scene.instantiate() as Main

@onready var player_name_scene := load(player_name_scene_path)
@onready var player_names := $CenterContainer/VBoxContainer/PlayerNames
@onready var ok_button := $CenterContainer/VBoxContainer/Cockpit/Ok as Button


func set_player(player: Player):
	self_player = player


func _ready():
	# To distinguish logs
	push_warning("player ", self_player.multiplayer_id, ": ", self_player.name)
	
	if multiplayer.is_server():
		main.server_add_player(self_player)
		
		var player_name_label := player_name_scene.instantiate() as Label
		player_name_label.set_text(self_player.name)
		player_name_label.set_name("PlayerName" + str(self_player.multiplayer_id))
		
		player_names.add_child(player_name_label)
		
		multiplayer.peer_connected.connect(server_register_unnamed_player)
		multiplayer.peer_disconnected.connect(server_unregister_player)
	else:
		ok_button.set_visible(false)
		rpc_id(1, "server_update_name", self_player.name)
		
		multiplayer.server_disconnected.connect(client_disconnected)


func server_register_unnamed_player(id: int):
	main.server_add_player(Player.new(id, "Unnamed"))
	
	var player_name_label := player_name_scene.instantiate() as Label
	player_name_label.set_text("Unnamed")
	player_name_label.set_name("PlayerName" + str(id))
	
	player_names.add_child(player_name_label)


func server_unregister_player(id: int):
	main.server_remove_player(id)
	
	var player_name_label = player_names.get_node("PlayerName" + str(id))
	player_name_label.queue_free()


@rpc("any_peer", "call_remote", "reliable")
func server_update_name(name: String):
	var id = multiplayer.get_remote_sender_id()
	main.server_update_player(Player.new(id, name))
	
	var player_name_label = player_names.get_node("PlayerName" + str(id))
	player_name_label.set_text(name)


func client_disconnected():
	_go_to_previous()


func _on_return_button_pressed():
	var peer = multiplayer.get_multiplayer_peer()
	
	if multiplayer.is_server():
		for player_id in players:
			peer.disconnect_peer(player_id)
		
		_go_to_previous()
		peer.close()
	else:
		# This will trigger client_disconnected which will _go_to_previous
		peer.close()


func _go_to_previous():
	var root := $/root
	root.remove_child(self)
	root.add_child(previous)
	queue_free()


@rpc("authority", "call_local", "reliable")
func go_to_main():
	var root := $/root
	root.remove_child(self)
	root.add_child(main)
	queue_free()


func _on_ok_pressed():
	if multiplayer.is_server():
		rpc("go_to_main")
