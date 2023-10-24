class_name Lobby
extends Control


@export_file var previous_scene_path: String
@export_file var main_scene_path: String
@export_file var player_entry_scene_path: String

@onready var player_entry_scene := load(player_entry_scene_path)
@onready var player_entries := $CenterContainer/VBoxContainer/PlayerEntries
@onready var ok_button := $CenterContainer/VBoxContainer/Cockpit/Ok as Button
@onready var color_selector := $CenterContainer/VBoxContainer/ColorSelector as ColorSelector


# This class (and ONLY this class) manages multiplayer_data

func _ready():
	multiplayer_data.is_multiplayer = true
	
	var self_player = multiplayer_data.self_player
	color_selector.set_pick_color(self_player.color)
	
	# To distinguish logs
	push_warning("player ", self_player.multiplayer_id, ": ", self_player.name)
	
	if multiplayer.is_server():
		multiplayer_data.server_clear_players()
		multiplayer_data.server_insert_player(self_player)
		
		var player_entry_label := player_entry_scene.instantiate() as LobbyPlayerEntry
		player_entry_label.set_name("PlayerName" + str(self_player.multiplayer_id))
		player_entry_label.set_player_id(self_player.multiplayer_id)
		
		player_entries.add_child(player_entry_label)
		
		multiplayer.peer_connected.connect(server_register_unnamed_player)
		multiplayer.peer_disconnected.connect(server_unregister_player)
	else:
		ok_button.set_visible(false)
		rpc_id(1, "server_update_player", self_player.name, self_player.color)
		
		multiplayer.server_disconnected.connect(client_disconnected)


func server_register_unnamed_player(id: int):
	multiplayer_data.server_insert_player(Player.new(id, "Loading...", Color.WHITE))
	
	var player_entry_label := player_entry_scene.instantiate() as LobbyPlayerEntry
	player_entry_label.set_name("PlayerName" + str(id))
	player_entry_label.set_player_id(id)
	
	player_entries.add_child(player_entry_label)


func server_unregister_player(id: int):
	multiplayer_data.server_remove_player(id)


@rpc("any_peer", "call_remote", "reliable")
func server_update_player(name: String, color: Color):
	var id = multiplayer.get_remote_sender_id()
	multiplayer_data.server_rename_player(id, name)
	multiplayer_data.server_recolor_player(id, color)


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


func _on_color_selector_color_changed(color):
	var previous_player = multiplayer_data.self_player
	var new_player = Player.new(previous_player.multiplayer_id, previous_player.name, color)
	multiplayer_data.update_player(new_player)


func _on_color_selector_color_changed_debounced(color):
	config.set_default_multiplayer_color(color)
	config.persist()
