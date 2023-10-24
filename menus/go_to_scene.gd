class_name GoToSceneButton
extends Button


@export_file var next_scene_path: String


func set_scene(new_scene: String):
	next_scene_path = new_scene


func _on_pressed():
	get_tree().change_scene_to_file(next_scene_path)
