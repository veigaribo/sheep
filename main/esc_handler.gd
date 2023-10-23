class_name EscHandler
extends Node

# Should only trigger on the server
signal server_someone_returning_to_lobby(id: int)
# Should trigger on both
signal returning_to_lobby()

@export_file var main_menu_path: String


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if multiplayer_data.is_multiplayer:
			rpc("multiplayer_return_to_lobby")
		else:
			singleplayer_return_to_lobby()


func singleplayer_return_to_lobby():
	get_tree().paused = false
	get_tree().change_scene_to_file(main_menu_path)


@rpc("any_peer", "call_local", "reliable")
func multiplayer_return_to_lobby():
	var sender = multiplayer.get_remote_sender_id()
	var myself = multiplayer.get_unique_id()
	
	if multiplayer.is_server() and sender != 1:
		server_someone_returning_to_lobby.emit(sender)
	
	if sender == 1 or sender == myself:
		get_tree().paused = false
		returning_to_lobby.emit()
