class_name SheepSpawner
extends Node


@export var sheep_count: int = 10
@export var shepherd: Shepherd
@export var wander_indicator: Node2D

var _sheep_scene := preload("sheep/sheep.tscn")

@onready var _main := $/root/Main as Main


func _ready():
	for i in range(sheep_count):
		_spawn_sheep.call_deferred()


func _spawn_sheep():
	var screen_size := get_viewport().get_visible_rect().size
	
	var sheep := _sheep_scene.instantiate() as Sheep
	sheep.position.x = rng.rand.randf_range(0, screen_size.x)
	sheep.position.y = rng.rand.randf_range(0, screen_size.y)
	sheep.shepherd = shepherd
	sheep.wander_indicator = wander_indicator
	
	_main.add_child(sheep)
	sheep.move_and_slide()
	
	if sheep.is_on_wall():
		sheep.free()
		_spawn_sheep()
