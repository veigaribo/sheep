class_name Main
extends Node2D


signal kickoff
signal returning_to_lobby

@export_file var main_menu_path: String
@export_file var shepherd_scene_path: String

var server_shepherds := {}
var shepherd_scene: Resource

@onready var _timer := $Timer as CountdownTimer
@onready var _player_names := $HUD/PlayerNames as Label
@onready var _tree := get_tree()


func _ready() -> void:
	print('multiplayer ', multiplayer)
	print('peer ', multiplayer.get_multiplayer_peer())
	
	if multiplayer_data.is_multiplayer:
		# Multiplayer
		if multiplayer.is_server():
			_server_display_player_names()
	else:
		# Singleplayer
		_server_create_shepherd(Player.new(1, "", Color.WHITE))
	
	if multiplayer.is_server():
		_server_create_shepherds()
	
	multiplayer.server_disconnected.connect(client_disconnected)
	multiplayer_data.server_player_quit.connect(server_player_disconnected)
	
	_tree.paused = true
	
	if multiplayer.is_server():
		_timer.kickoff.connect(func _server_kickoff():
			rpc("do_kickoff"))


func _server_create_shepherd(player: Player):
	var shepherd := _get_shepherd_scene().instantiate() as Shepherd
	shepherd.server_set_player(player)
	shepherd.set_name("Shepherd" + str(player.multiplayer_id))
	
	server_shepherds[player.multiplayer_id] = shepherd
	add_child(shepherd, true)


func _server_create_shepherds():
	for player in multiplayer_data.server_get_players():
		_server_create_shepherd(player)


func _server_remove_shepherd(id: int):
	if id in server_shepherds:
		server_shepherds[id].queue_free()


func _server_display_player_names():
	var players := multiplayer_data.server_get_players()
	var player_names := players.pop_front().name as String
	
	for player in players:
		player_names += ", "
		player_names += player.name
	
	_player_names.set_text(player_names)


func _get_shepherd_scene() -> Resource:
	if shepherd_scene == null:
		shepherd_scene = load(shepherd_scene_path)
	
	return shepherd_scene


@rpc("authority", "call_local", "reliable")
func do_kickoff():
	_tree.paused = false
	kickoff.emit()


func client_disconnected():
	get_tree().paused = false
	get_tree().change_scene_to_file(main_menu_path)


func server_player_disconnected(player: Player):
	_server_remove_shepherd(player.multiplayer_id)


# This client is returning to lobby
func _on_esc_handler_returning_to_lobby():
	returning_to_lobby.emit()
	queue_free()


# This is the server and some client is returning to lobby
func _server_on_esc_handler_someone_returning_to_lobby(id):
	if multiplayer.is_server():
		_server_remove_shepherd(id)
