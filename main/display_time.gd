class_name DisplayTime
extends Label


var _running := false
var _start: int


func _ready() -> void:
	set_text("00:00.000")


# Only count significant frames
func _physics_process(_delta: float) -> void:
	if not multiplayer.is_server():
		return
	
	if _running:
		set_text(_server_format())


func _server_format() -> String:
	var current_msec := Time.get_ticks_msec()
	var elapsed := current_msec - _start
	
	var elapsed_seconds := elapsed / 1000
	
	var minutes := elapsed_seconds / 60
	var seconds := elapsed_seconds % 60
	var msec := elapsed % 1000
	
	return "%02d:%02d.%03d" % [minutes, seconds, msec]


func _on_win() -> void:
	_running = false


func _on_timer_kickoff() -> void:
	if not multiplayer.is_server():
		return
	
	_running = true
	_start = Time.get_ticks_msec()
