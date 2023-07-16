class_name CountdownLabel
extends Label


func _ready() -> void:
	pass


func _on_timer_tick(remaining: int) -> void:
	set_text(str(remaining))


func _on_timer_kickoff() -> void:
	queue_free()
