class_name MultiplayerData
extends Node


signal player_joined(player: Player)
signal player_quit(player: Player)

var self_player: Player = null
var is_multiplayer := false

var server_players := {}


func insert_player(player: Player):
	update_player(player)
	player_joined.emit(player)


func update_player(player: Player):
	server_players[player.multiplayer_id] = player


func remove_player(id: int):
	var player = server_players[id]
	server_players.erase(id)
	
	player_quit.emit(player)


func rename_player(id: int, name: String):
	server_players[id].name = name


func get_players() -> Array:
	return server_players.values()
