class_name Corral
extends Area2D


signal corralled(total: int)
signal won

@export var sheep_to_win: int

var _sheep_inside: int = 0


func _ready() -> void:
	pass


func _process(_delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Sheep"):
		_sheep_inside += 1
		corralled.emit(_sheep_inside)
		
		if _sheep_inside >= sheep_to_win:
			won.emit()


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Sheep"):
		_sheep_inside -= 1
		corralled.emit(_sheep_inside)
