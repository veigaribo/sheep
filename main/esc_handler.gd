class_name EscHandler
extends Node


@export_file var main_menu_path: String

@onready var main := $'..' as Main


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		multiplayer.get_multiplayer_peer().close()
		
		if multiplayer.is_server():
			get_tree().change_scene_to_file(main_menu_path)
	
		get_tree().paused = false
