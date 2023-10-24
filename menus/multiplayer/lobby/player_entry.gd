class_name PlayerEntry
extends Control


var player_id: int

@onready var label := $HBoxContainer/Label as Label

# Icon can't be a TextureRect because cropping would occur inside of the texture
# and so MultiplayerSynchronizer wouldn't be able to synchronize
@onready var icon := $HBoxContainer/StatusIcon as Sprite2D


func set_player_id(id: int):
	player_id = id


func _ready():
	if multiplayer.is_server():
		if player_id in multiplayer_data.server_players:
			var player = multiplayer_data.server_players[player_id]
			_server_set_player_name(player.name)
			_server_set_player_color(player.color)
	
		multiplayer_data.server_player_joined.connect(_server_maybe_update_player)
		multiplayer_data.server_player_updated.connect(_server_maybe_update_player)
		multiplayer_data.server_player_quit.connect(_server_maybe_remove_player)


func _server_maybe_update_player(player: Player):
	if player.multiplayer_id == player_id:
		_server_set_player_name(player.name)
		_server_set_player_color(player.color)
		_server_set_player_state(player.state)


func _server_maybe_remove_player(player: Player):
	if player.multiplayer_id == player_id:
		queue_free()


func _server_set_player_name(name: String):
	label.set_text(name)


func _server_set_player_color(color: Color):
	label.set_modulate(color)


func _server_set_player_state(status: Player.States):
	match status:
		Player.States.IN_LOBBY:
			icon.set_frame(346)
		Player.States.PLAYING:
			icon.set_frame(344)
