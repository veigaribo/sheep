class_name MultiplayerData
extends Node


signal server_player_joined(player: Player)
signal server_player_updated(new_player: Player)
signal server_player_quit(player: Player)

var self_player: Player = null
var is_multiplayer := false

var server_players := {}


func update_player(player: Player):
	self_player = player
	
	if multiplayer.is_server():
		server_update_player(player)
	else:
		rpc_id(1, "server_remote_update_player", _serialize_player(player))


func server_clear_players():
	server_players = {}


func server_insert_player(player: Player):
	server_update_player(player)
	server_player_joined.emit(player)


func server_update_player(player: Player):
	server_players[player.multiplayer_id] = player
	server_player_updated.emit(player)


@rpc("any_peer", "call_remote", "reliable")
func server_remote_update_player(player: Array):
	server_update_player(_deserialize_player(player))


func server_remove_player(id: int):
	var player = server_players[id]
	server_players.erase(id)
	
	server_player_quit.emit(player)


func server_rename_player(id: int, name: String):
	server_players[id].name = name
	server_player_updated.emit(server_players[id])


func server_recolor_player(id: int, color: Color):
	server_players[id].color = color
	server_player_updated.emit(server_players[id])


func server_get_players() -> Array:
	return server_players.values()


func _serialize_player(player: Player) -> Array:
	return [player.multiplayer_id, player.name, player.color]


func _deserialize_player(player: Array) -> Player:
	return Player.new(player[0], player[1], player[2])
