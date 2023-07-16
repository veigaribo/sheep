class_name PlayButton
extends Button


@export var play_scene: PackedScene


func _on_pressed():
	get_tree().change_scene_to_packed(play_scene)
