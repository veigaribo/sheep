class_name CreditsButton
extends Button


@export var credits_scene: PackedScene


func _on_pressed():
	get_tree().change_scene_to_packed(credits_scene)
