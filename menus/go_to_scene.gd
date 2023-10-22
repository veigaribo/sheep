class_name GoToSceneButton
extends Button


@export var parent_scene: Node
@export_file var next_scene_path: String


func set_scene(new_scene: String):
	next_scene_path = new_scene


func _on_pressed():
	var next_scene := load(next_scene_path)
	var next := next_scene.instantiate() as Node
	
	var root := $/root
	root.remove_child(parent_scene)
	root.add_child(next)
	queue_free()
