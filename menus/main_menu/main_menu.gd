extends Control


@onready var _version_button := $Version as Button


func _ready():
	# Ensure we're clean
	multiplayer.get_multiplayer_peer().close() # Paranoia
	multiplayer.set_multiplayer_peer(OfflineMultiplayerPeer.new())
	multiplayer_data.is_multiplayer = false
	multiplayer_data.server_clear_players()
	
	_load_version()


func _load_version():
	var file = ConfigFile.new()
	file.load("res://version.cfg")
	
	var version = file.get_value("game", "version")
	var commit = file.get_value("game", "commit")
	
	_version_button.set_text(version + " [" + commit.substr(0, 10) + "]")


func _on_version_pressed():
	DisplayServer.clipboard_set(_version_button.get_text())
