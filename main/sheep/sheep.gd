class_name Sheep
extends CharacterBody2D


enum State {
	IDLE,
	WANDER,
	HERD
}

@export var speed := 300.0
@export var acceleration := 200.0

var shepherd: Shepherd
var wander_indicator: Node2D

var _state := State.IDLE

@onready var _wanderer := $Wanderer as Wanderer
@onready var _wandering_to := global_position
@onready var _animation_tree := $AnimationTree as AnimationTree
@onready var _animation_state := _animation_tree.get("parameters/playback") as AnimationNodeStateMachinePlayback

func _ready() -> void:
	_wanderer.start()
	shepherd.body_entered.connect(_on_herded)
	shepherd.body_exited.connect(_on_unherded)


func _physics_process(delta: float) -> void:
	match _state:
		State.IDLE: _physics_idle(delta)
		State.WANDER: _physics_wander(delta)
		State.HERD: _physics_herd(delta)


func _to_state(new_state: State) -> void:
	match new_state:
		State.IDLE:
			if _state != State.WANDER:
				_wanderer.start()
				
			_animation_state.travel("Idle")
		State.WANDER:
			_animation_state.travel("Translating")
			_wanderer.start()
		State.HERD:
			_animation_state.travel("Translating")
			_wanderer.stop()
	
	_state = new_state


func _physics_idle(_delta: float) -> void:
	pass


func _physics_wander(delta: float) -> void:
	var distance_to_target := global_position.distance_to(_wandering_to)
	
	if distance_to_target > speed * delta:
		var collided = _move_to(_wandering_to, delta)
		if collided:
			_stop()
	else:
		_stop()


func _physics_herd(delta: float) -> void:
	var shepherd_pos := shepherd.get_global_position()
	var diff_pos := global_position - shepherd_pos
	var direction := diff_pos.normalized()
	
	_move_in_direction(direction, delta)


func _stop() -> void:
	velocity = Vector2.ZERO
	_to_state(State.IDLE)


func _move_in_direction(direction: Vector2, delta: float) -> bool:
	_set_facing(direction)
	
	var target_velocity := direction * speed
	var delta_acceleration := delta * acceleration
	
	velocity = velocity.move_toward(
		target_velocity,
		delta_acceleration
	)
	
	return move_and_slide()


func _move_to(target_position: Vector2, delta: float) -> bool:
	var direction := global_position.direction_to(
		target_position
	)
	
	return _move_in_direction(direction, delta)


func _set_facing(direction: Vector2) -> void:
	_animation_tree.set("parameters/Idle/blend_position", direction.x)
	_animation_tree.set("parameters/Translating/blend_position", direction.x)


func _on_wander(target_position: Vector2) -> void:
	if _state in [State.IDLE, State.WANDER]:
		_wandering_to = target_position
		_to_state(State.WANDER)
		
		if wander_indicator:
			wander_indicator.set_global_position(_wandering_to)


func _on_herded(body: Node2D) -> void:
	if body == self:
		_to_state(State.HERD)


func _on_unherded(body: Node2D) -> void:
	if body == self:
		_stop()
