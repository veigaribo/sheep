class_name Main
extends Node2D


@export_file var main_menu_path: String
@export_file var shepherd_scene_path: String

var server_shepherds := {}
var shepherd_scene: Resource

@onready var main_menu_scene := load(main_menu_path)
@onready var main_menu := main_menu_scene.instantiate() as Control

@onready var _timer := $Timer as CountdownTimer
@onready var _player_names := $HUD/PlayerNames as Label
@onready var _tree := get_tree()


func _ready() -> void:
	if multiplayer_data.is_multiplayer:
		# Multiplayer
		if multiplayer.is_server():
			_server_display_player_names()
	else:
		# Singleplayer
		_server_create_shepherd(Player.new(1, ""))
	
	if multiplayer.is_server():
		_server_create_shepherds()
	
	multiplayer.server_disconnected.connect(client_disconnected)
	
	if multiplayer.is_server():
		multiplayer.peer_disconnected.connect(server_player_disconnected)
	
	_tree.paused = true
	await _timer.kickoff
	_tree.paused = false


func _server_create_shepherd(player: Player):
	var shepherd := _get_shepherd_scene().instantiate() as Shepherd
	shepherd.server_player = player
	shepherd.set_name("Shepherd" + str(player.multiplayer_id))
	
	server_shepherds[player.multiplayer_id] = shepherd
	add_child(shepherd)


func _server_create_shepherds():
	for player in multiplayer_data.get_players():
		_server_create_shepherd(player)


func _server_display_player_names():
	var players := multiplayer_data.get_players()
	var player_names := players.pop_front().name as String
	
	for player in players:
		player_names += ", "
		player_names += player.name
	
	_player_names.set_text(player_names)


func _get_shepherd_scene() -> Resource:
	if shepherd_scene == null:
		shepherd_scene = load(shepherd_scene_path)
	
	return shepherd_scene


func client_disconnected():
	get_tree().paused = false
	get_tree().change_scene_to_file(main_menu_path)


func server_player_disconnected(id: int):
	multiplayer_data.remove_player(id)
	
	if id in server_shepherds:
		server_shepherds[id].queue_free()
