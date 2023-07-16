class_name CountdownSoundPlayer
extends AudioStreamPlayer


func _on_timer_tick(_remaining: int) -> void:
	play()


func _on_timer_kickoff():
	queue_free()
