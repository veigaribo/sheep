class_name Sheep
extends CharacterBody2D


enum State {
	IDLE,
	WANDER,
	HERD
}

@export var speed := 300.0
@export var acceleration := 200.0

var _state := State.IDLE

var herding_shepherds: Array

# For the replay
var history: Array

@onready var _wanderer := $Wanderer as Wanderer
@onready var _wandering_to := global_position
@onready var _animation_tree := $AnimationTree as AnimationTree
@onready var _animation_state := _animation_tree.get("parameters/playback") as AnimationNodeStateMachinePlayback


func _ready() -> void:
	if not multiplayer.is_server():
		return
	
	_wanderer.start_timer()


func _physics_process(delta: float) -> void:
	history.push_back(self.transform)
	
	if not multiplayer.is_server():
		return
	
	match _state:
		State.IDLE: _server_physics_idle(delta)
		State.WANDER: _server_physics_wander(delta)
		State.HERD: _server_physics_herd(delta)


func _server_to_state(new_state: State) -> void:
	match new_state:
		State.IDLE:
			if _state != State.WANDER:
				_wanderer.start_timer()
				
			rpc("animation_set_state", "Idle")
		State.WANDER:
			rpc("animation_set_state", "Translating")
			_wanderer.start_timer()
		State.HERD:
			rpc("animation_set_state", "Translating")
			_wanderer.stop_timer()
	
	_state = new_state


func _server_physics_idle(_delta: float) -> void:
	pass


func _server_physics_wander(delta: float) -> void:
	var distance_to_target := global_position.distance_to(_wandering_to)
	
	if distance_to_target > speed * delta:
		var collided = _server_move_to(_wandering_to, delta)
		if collided:
			_server_stop()
	else:
		_server_stop()


func _server_physics_herd(delta: float) -> void:
	var push_sum := Vector2.ZERO
	
	for _shepherd in herding_shepherds:
		var shepherd := _shepherd as Shepherd
		
		var shepherd_pos := shepherd.get_global_position()
		var away_direction = global_position - shepherd_pos
		
		var distance = away_direction.length()
		var push_force = 1.0 / (distance * distance)
		
		push_sum += away_direction * push_force
	
	var average_push := push_sum / herding_shepherds.size()
	
	var direction: Vector2
	if not is_zero_approx(average_push.length()):
		direction = average_push.normalized()
	else:
		direction = Vector2.ZERO
	
	server_move_in_direction(direction, delta)


func server_herd(shepherd: Shepherd) -> void:
	if _state != State.HERD:
		_server_to_state(State.HERD)
	
	_server_add_herding_shepherd(shepherd)


func _server_add_herding_shepherd(shepherd: Shepherd) -> void:
	for current_shepherd in herding_shepherds:
		if current_shepherd.server_player == shepherd.server_player:
			return
	
	herding_shepherds.push_back(shepherd)


func server_unherd(shepherd: Shepherd) -> void:
	_server_remove_herding_shepherd(shepherd)
	
	if herding_shepherds.is_empty():
		_server_stop()


func _server_remove_herding_shepherd(shepherd: Shepherd) -> void:
	var shepherd_i: int = -1
	
	for i in herding_shepherds.size():
		var current_shepherd := herding_shepherds[i] as Shepherd
		
		if current_shepherd.server_player == shepherd.server_player:
			shepherd_i = i
			break
	
	if shepherd_i != -1:
		herding_shepherds.remove_at(shepherd_i)


func _server_stop() -> void:
	velocity = Vector2.ZERO
	_server_to_state(State.IDLE)


func server_move_in_direction(direction: Vector2, delta: float) -> bool:
	rpc("animation_set_facing", direction)
	
	var target_velocity := direction * speed
	var delta_acceleration := delta * acceleration
	
	velocity = velocity.move_toward(
		target_velocity,
		delta_acceleration
	)
	
	var result := move_and_slide()
	
	# Push other sheep along
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		if collider is Sheep:
			var normal = collision.get_normal()
			var dot = direction.dot(normal)
			
			# Push in a single direction only
			if dot < 0:
				collider.server_move_in_direction(normal * -1, delta)
	
	return result


func _server_move_to(target_position: Vector2, delta: float) -> bool:
	var direction := global_position.direction_to(
		target_position
	)
	
	return server_move_in_direction(direction, delta)


@rpc("authority", "call_local", "unreliable")
func animation_set_facing(direction: Vector2) -> void:
	_animation_tree.set("parameters/Idle/blend_position", direction.x)
	_animation_tree.set("parameters/Translating/blend_position", direction.x)


@rpc("authority", "call_local", "unreliable")
func animation_set_state(state: String) -> void:
	_animation_state.travel(state)


func _on_wander(target_position: Vector2) -> void:
	if not multiplayer.is_server():
		return
	
	if _state in [State.IDLE, State.WANDER]:
		_wandering_to = target_position
		_server_to_state(State.WANDER)
