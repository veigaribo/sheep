class_name BackButton
extends Button


@export_file var main_scene: String


func _on_pressed():
	get_tree().change_scene_to_file(main_scene)
