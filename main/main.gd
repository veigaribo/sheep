class_name Main
extends Node2D


@export_file var main_menu_path: String
@export_file var shepherd_scene_path: String

var shepherds := {}
var shepherd_scene: Resource

@onready var main_menu_scene := load(main_menu_path)
@onready var main_menu := main_menu_scene.instantiate() as Control

@onready var _timer := $Timer as CountdownTimer
@onready var _tree := get_tree()


func server_add_player(player: Player):
	var shepherd := _get_shepherd_scene().instantiate() as Shepherd
	shepherd.server_player = player
	shepherd.set_name("Shepherd" + str(player.multiplayer_id))
	
	shepherds[player.multiplayer_id] = shepherd


func server_remove_player(id: int):
	shepherds.erase(id)
	
	var maybe_spawned = get_node("Shepherd" + str(id))
	if maybe_spawned != null:
		maybe_spawned.queue_free()


func server_update_player(player: Player):
	shepherds[player.multiplayer_id].server_player = player


func _ready() -> void:
	if shepherds.size() > 0:
		# Multiplayer
		for id in shepherds:
			var shepherd := shepherds[id] as Shepherd
			add_child(shepherd)
	else:
		# Singleplayer
		var shepherd := _get_shepherd_scene().instantiate() as Shepherd
		shepherd.server_player = Player.new(1, "")
		add_child(shepherd)
	
	multiplayer.server_disconnected.connect(client_disconnected)
	
	if multiplayer.is_server():
		multiplayer.peer_disconnected.connect(server_disconnected)
	
	_tree.paused = true
	await _timer.kickoff
	_tree.paused = false


func _get_shepherd_scene() -> Resource:
	if shepherd_scene == null:
		shepherd_scene = load(shepherd_scene_path)
	
	return shepherd_scene


func client_disconnected():
	var root := $/root
	root.remove_child(self)
	root.add_child(main_menu)
	queue_free()


func server_disconnected(id: int):
	server_remove_player(id)
