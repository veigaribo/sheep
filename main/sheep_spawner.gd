class_name SheepSpawner
extends Node


@export var sheep_count: int = 10
@export var shepherd: Shepherd
@export var wander_indicator: Node2D

var _sheep_scene := preload("sheep/sheep.tscn")
var _sheep_constrainer: SheepSpawnerConstrainer

@onready var _main := $/root/Main as Main
@onready var _sampler := $PointSampler as PointSampler2D


func _ready():
	_setup_sampler()
	
	for i in range(sheep_count):
		_spawn_sheep.call_deferred()


func _setup_sampler():
	var corral_polygon = 0
	var left_side_polygons = [1, 2]
	var right_side_polygons = [4, 5]
	var polygon_count = 6
	
	_sheep_constrainer = SheepSpawnerConstrainer.new(
		polygon_count,
		corral_polygon,
		left_side_polygons,
		right_side_polygons,
	)
	
	_sampler.biases = _sheep_constrainer.biases


func _spawn_sheep():
	var screen_size := get_viewport().get_visible_rect().size
	
	var sheep := _sheep_scene.instantiate() as Sheep
	var sampler_result := _sampler.random_point()
	
	sheep.position = sampler_result.position
	sheep.shepherd = shepherd
	sheep.wander_indicator = wander_indicator
	
	_main.add_child(sheep)
	sheep.move_and_slide()
	
	if sheep.is_on_wall():
		sheep.free()
		_spawn_sheep()
	else:
		_sheep_constrainer.update(sampler_result.polygon)


class SheepSpawnerConstrainer:
	const MAX_AT_CORRAL: int = 2
	const MAX_AT_LEFT: int = 8
	const MAX_AT_RIGHT: int = 8
	
	var polygon_count: int
	var corral_polygon: int
	var left_side_polygons: Array
	var right_side_polygons: Array
	
	var _sheep_spawned_at_corral: int
	var _sheep_spawned_left_side: int
	var _sheep_spawned_right_side: int
	
	var biases: Array
	
	func _init(
		polygon_count: int,
		corral_polygon: int,
		left_side_polygons: Array,
		right_side_polygons: Array
	):
		self.polygon_count = polygon_count
		self.corral_polygon = corral_polygon
		self.left_side_polygons = left_side_polygons
		self.right_side_polygons = right_side_polygons
		
		biases = Array()
		biases.resize(polygon_count)
		biases.fill(1.0)
		
		_check_corral()
		_check_left()
		_check_right()
	
	func update(polygon_index: int):
		if polygon_index == corral_polygon:
			_sheep_spawned_at_corral += 1
			_check_corral()
		elif polygon_index in left_side_polygons:
			_sheep_spawned_left_side += 1
			_check_left()
		elif polygon_index in right_side_polygons:
			_sheep_spawned_right_side += 1
			_check_right()
	
	func _check_corral():
		if _sheep_spawned_at_corral >= MAX_AT_CORRAL:
			biases[corral_polygon] = 0
	
	func _check_left():
		if _sheep_spawned_left_side >= MAX_AT_LEFT:
			for i in left_side_polygons:
				biases[i] = 0
	
	func _check_right():
		if _sheep_spawned_right_side >= MAX_AT_RIGHT:
			for i in right_side_polygons:
				biases[i] = 0
