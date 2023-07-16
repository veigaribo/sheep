class_name Main
extends Node2D


@onready var _timer := $Timer as CountdownTimer
@onready var _tree := get_tree()


func _ready() -> void:
	_tree.paused = true
	await _timer.kickoff
	_tree.paused = false


func _process(_delta: float) -> void:
	pass
