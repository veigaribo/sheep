class_name Wanderer
extends Node


signal wander(target_position)

@export var target: Node2D
@export var wander_rect_length: int = 64
@export var min_wander_time_s: int = 1
@export var max_wander_time_s: int = 3

@onready var _start_position := target.global_position
@onready var _target_position := _start_position
@onready var _timer := $Timer as Timer


func start() -> void:
	_start_timer()


func stop() -> void:
	_timer.stop()


func _start_timer() -> void:
	var time_s := rng.rand.randf_range(min_wander_time_s, max_wander_time_s)
	_timer.start(time_s)


func _on_timeout() -> void:
	var x_component := rng.rand.randf_range(-wander_rect_length, wander_rect_length)
	var y_component := rng.rand.randf_range(-wander_rect_length, wander_rect_length)
	var displacement := Vector2(x_component, y_component)
	
	_target_position = _start_position + displacement
	wander.emit(_target_position)
	
	_start_timer()
