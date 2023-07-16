class_name Shepherd
extends Area2D


var _herd_count: int = 0

@onready var _animation_tree := $AnimationTree as AnimationTree
@onready var _animation_state := _animation_tree.get("parameters/playback") as AnimationNodeStateMachinePlayback


func _ready() -> void:
	pass


func _process(_delta: float) -> void:
	var mouse_pos := get_viewport().get_mouse_position()
	set_global_position(mouse_pos)


func _on_herding(body: Node2D) -> void:
	if body.is_in_group("Sheep"):
		_herd_count += 1
		_animation_state.travel("Herding")


func _on_not_herding(body: Node2D) -> void:
	if body.is_in_group("Sheep"):
		_herd_count -= 1
		
		if _herd_count == 0:
			_animation_state.travel("Idle")
