class_name Lobby
extends Control


@export_file var previous_scene_path: String
@export_file var main_scene_path: String
@export_file var player_name_scene_path: String

@onready var player_name_scene := load(player_name_scene_path)
@onready var player_names := $CenterContainer/VBoxContainer/PlayerNames
@onready var ok_button := $CenterContainer/VBoxContainer/Cockpit/Ok as Button


# This class (and ONLY this class) manages multiplayer_data

func _ready():
	var self_player = multiplayer_data.self_player
	multiplayer_data.is_multiplayer = true
	# To distinguish logs
	push_warning("player ", self_player.multiplayer_id, ": ", self_player.name)
	
	if multiplayer.is_server():
		multiplayer_data.server_clear_players()
		multiplayer_data.server_insert_player(self_player)
		
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
	multiplayer_data.server_insert_player(Player.new(id, "Unnamed"))
	
	var player_name_label := player_name_scene.instantiate() as Label
	player_name_label.set_text("Unnamed")
	player_name_label.set_name("PlayerName" + str(id))
	
	player_names.add_child(player_name_label)


func server_unregister_player(id: int):
	multiplayer_data.server_remove_player(id)
	
	var player_name_label = player_names.get_node("PlayerName" + str(id))
	player_name_label.queue_free()


@rpc("any_peer", "call_remote", "reliable")
func server_update_name(name: String):
	var id = multiplayer.get_remote_sender_id()
	multiplayer_data.server_rename_player(id, name)
	
	var player_name_label = player_names.get_node("PlayerName" + str(id))
	player_name_label.set_text(name)


func client_disconnected():
	_go_to_previous()


func _on_return_button_pressed():
	var peer = multiplayer.get_multiplayer_peer()
	
	if multiplayer.is_server():
		_go_to_previous()
		peer.close()
	else:
		# This will trigger client_disconnected which will _go_to_previous
		peer.close()


func _go_to_previous():
	get_tree().change_scene_to_file(previous_scene_path)


@rpc("authority", "call_local", "reliable")
func go_to_main():
	set_visible(false)
	
	var main_scene := load(main_scene_path)
	var main := main_scene.instantiate() as Main
	
	main.returning_to_lobby.connect(_on_returning_to_lobby)
	add_sibling(main)


func _on_ok_pressed():
	if multiplayer.is_server():
		rpc("go_to_main")


func _on_returning_to_lobby():
	set_visible(true)
