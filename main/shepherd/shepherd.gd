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
		server_update_position(1, mouse_pos)
	else:
		var id = multiplayer.get_unique_id()
		rpc_id(1, "server_update_position", id, mouse_pos)


@rpc("any_peer", "call_remote", "unreliable_ordered")
func server_update_position(id: int, mouse_pos: Vector2):
	if server_player.multiplayer_id == id:
		set_global_position(mouse_pos)


func _on_herding(body: Node2D) -> void:
	if body.is_in_group("Sheep"):
		_herd_count += 1
		_animation_state.travel("Herding")
		
		if multiplayer.is_server():
			body.herd(self)


func _on_not_herding(body: Node2D) -> void:
	if body.is_in_group("Sheep"):
		_herd_count -= 1
		
		if _herd_count == 0:
			_animation_state.travel("Idle")
		
		if multiplayer.is_server():
			body.unherd(self)
