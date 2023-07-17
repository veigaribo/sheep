class_name EscHandler
extends Node


@export_file var main_menu: String

@onready var _tree := get_tree()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_tree.change_scene_to_file(main_menu)
		_tree.paused = false
