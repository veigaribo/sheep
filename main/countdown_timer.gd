class_name CountdownTimer
extends Timer


signal tick(remaining: int)
signal kickoff

@export var counter: int = 3


func _ready() -> void:
	tick.emit(counter)


func _on_timeout() -> void:
	counter -= 1
	tick.emit(counter)
	
	if counter <= 0:
		_kickoff()


func _kickoff() -> void:
	stop()
	kickoff.emit()
