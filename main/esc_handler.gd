class_name EscHandler
extends Node


@export_file var main_menu: String

@onready var _tree := get_tree()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		_tree.change_scene_to_file(main_menu)
		_tree.paused = false
