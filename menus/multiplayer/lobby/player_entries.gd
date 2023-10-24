class_name PlayerEntries
extends VBoxContainer


@export_file var player_entry_scene_path: String

@onready var player_entry_scene := load(player_entry_scene_path)


func _ready():
	if multiplayer.is_server():
		for player in multiplayer_data.server_get_players():
			_add_player(player)
		
		multiplayer_data.server_player_joined.connect(_on_player_joined)


func _entry_name_for(player: Player):
	return "PlayerName" + str(player.multiplayer_id)


func _add_player(player: Player):
	var player_entry_label := player_entry_scene.instantiate() as PlayerEntry
	player_entry_label.set_name(_entry_name_for(player))
	player_entry_label.set_player_id(player.multiplayer_id)
	
	add_child(player_entry_label, true)


func _on_player_joined(player: Player):
	_add_player(player)
