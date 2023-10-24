extends Control


func _ready():
	# Ensure we're home
	multiplayer.get_multiplayer_peer().close() # Paranoia
	multiplayer.set_multiplayer_peer(OfflineMultiplayerPeer.new())
	multiplayer_data.is_multiplayer = false
	multiplayer_data.server_clear_players()
