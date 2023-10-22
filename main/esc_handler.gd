class_name EscHandler
extends Node


@export_file var main_menu_path: String

@onready var main := $'..' as Main
@onready var _tree := get_tree()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		multiplayer.get_multiplayer_peer().close()
		
		if multiplayer.is_server():
			var main_menu_scene := load(main_menu_path)
			var main_menu := main_menu_scene.instantiate() as Control
			
			var root := $/root
			root.remove_child(main)
			root.add_child(main_menu)
			queue_free()
	
		_tree.paused = false
