class_name Shepherd
extends Area2D


var server_player: Player

var _herd_count: int = 0

@onready var _animation_tree := $AnimationTree as AnimationTree
@onready var _animation_state := _animation_tree.get("parameters/playback") as AnimationNodeStateMachinePlayback


func _ready() -> void:
	pass


func _process(_delta: float) -> void:
	var mouse_pos := get_viewport().get_mouse_position()
	
	if multiplayer.is_server():
		if server_player.multiplayer_id == 1:
			server_set_position(mouse_pos)
	else:
		rpc_id(1, "server_update_position", mouse_pos)


@rpc("any_peer", "call_remote", "unreliable_ordered")
func server_update_position(mouse_pos: Vector2):
	var sender_id = multiplayer.get_remote_sender_id()
	
	if server_player.multiplayer_id == sender_id:
		server_set_position(mouse_pos)


func server_set_position(pos: Vector2):
	set_global_position(pos)


func _on_herding(body: Node2D) -> void:
	if body.is_in_group("Sheep"):
		_herd_count += 1
		_animation_state.travel("Herding")
		
		if multiplayer.is_server():
			body.server_herd(self)


func _on_not_herding(body: Node2D) -> void:
	if body.is_in_group("Sheep"):
		_herd_count -= 1
		
		if _herd_count == 0:
			_animation_state.travel("Idle")
		
		if multiplayer.is_server():
			body.server_unherd(self)
