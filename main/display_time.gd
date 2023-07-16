class_name DisplayTime
extends Label


var _running := false
var _start: int


func _ready() -> void:
	set_text("00:00")


func _process(_delta: float) -> void:
	if _running:
		set_text(_format())


func _format() -> String:
	var current_msec := Time.get_ticks_msec()
	var elapsed := current_msec - _start
	
	var elapsed_seconds := elapsed / 1000
	
	var minutes = elapsed_seconds / 60
	var seconds = elapsed_seconds % 60
	
	return "%02d:%02d" % [minutes, seconds]


func _on_win() -> void:
	_running = false


func _on_timer_kickoff() -> void:
	_running = true
	_start = Time.get_ticks_msec()
