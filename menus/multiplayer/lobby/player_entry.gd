class_name LobbyPlayerEntry
extends Control


var player_id: int

@onready var label := $HBoxContainer/Label as Label


func set_player_id(id: int):
	player_id = id


func _ready():
	if multiplayer.is_server():
		if player_id in multiplayer_data.server_players:
			var player = multiplayer_data.server_players[player_id]
			_set_player_name(player.name)
			_set_player_color(player.color)
	
		multiplayer_data.server_player_joined.connect(_maybe_update_player)
		multiplayer_data.server_player_updated.connect(_maybe_update_player)
		multiplayer_data.server_player_quit.connect(_maybe_remove_player)


func _maybe_update_player(player: Player):
	if player.multiplayer_id == player_id:
		_set_player_name(player.name)
		_set_player_color(player.color)


func _maybe_remove_player(player: Player):
	if player.multiplayer_id == player_id:
		queue_free()


func _set_player_name(name: String):
	label.set_text(name)


func _set_player_color(color: Color):
	label.set_modulate(color)
