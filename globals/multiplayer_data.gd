class_name MultiplayerData
extends Node


signal server_player_joined(player: Player)
signal server_player_quit(player: Player)

var self_player: Player = null
var is_multiplayer := false

var server_players := {}


func server_clear_players():
	server_players = {}


func server_insert_player(player: Player):
	server_update_player(player)
	server_player_joined.emit(player)


func server_update_player(player: Player):
	server_players[player.multiplayer_id] = player


func server_remove_player(id: int):
	var player = server_players[id]
	server_players.erase(id)
	
	server_player_quit.emit(player)


func server_rename_player(id: int, name: String):
	server_players[id].name = name


func server_get_players() -> Array:
	return server_players.values()
