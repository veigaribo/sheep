class_name Main
extends Node2D


@export_file var main_menu_path: String
@export_file var shepherd_scene_path: String

var server_shepherds := {}
var shepherd_scene: Resource

var is_multiplayer := false

@onready var main_menu_scene := load(main_menu_path)
@onready var main_menu := main_menu_scene.instantiate() as Control

@onready var _timer := $Timer as CountdownTimer
@onready var _player_names := $HUD/PlayerNames as Label
@onready var _tree := get_tree()


func server_add_player(player: Player):
	var shepherd := _get_shepherd_scene().instantiate() as Shepherd
	shepherd.server_player = player
	shepherd.set_name("Shepherd" + str(player.multiplayer_id))
	
	server_shepherds[player.multiplayer_id] = shepherd


func server_remove_player(id: int):
	server_shepherds.erase(id)
	
	var maybe_spawned = get_node("Shepherd" + str(id))
	if maybe_spawned != null:
		maybe_spawned.queue_free()


func server_update_player(player: Player):
	server_shepherds[player.multiplayer_id].server_player = player


func set_multiplayer(is_multiplayer: bool):
	self.is_multiplayer = is_multiplayer


func _ready() -> void:
	if is_multiplayer:
		# Multiplayer
		for id in server_shepherds:
			var shepherd := server_shepherds[id] as Shepherd
			add_child(shepherd)
		
		if multiplayer.is_server():
			var player_names = server_shepherds[1].server_player.name
			
			for id in server_shepherds:
				if id == 1: continue
				
				player_names += ", "
				player_names += server_shepherds[id].server_player.name
			
			_player_names.set_text(player_names)
	else:
		# Singleplayer
		var shepherd := _get_shepherd_scene().instantiate() as Shepherd
		shepherd.server_player = Player.new(1, "")
		add_child(shepherd)
	
	multiplayer.server_disconnected.connect(client_disconnected)
	
	if multiplayer.is_server():
		multiplayer.peer_disconnected.connect(server_player_disconnected)
	
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


func server_player_disconnected(id: int):
	server_remove_player(id)
