extends Control


@export var version_data: JSON

@onready var _version_button := $Version as Button
@onready var _multiplayer_button := $CenterContainer/VBoxContainer/VBoxContainer/MultiplayerButton as Button


func _ready():
	if OS.get_name() == "Web":
		_multiplayer_button.disabled = true
	
	# Ensure we're clean
	multiplayer.get_multiplayer_peer().close() # Paranoia
	multiplayer.set_multiplayer_peer(OfflineMultiplayerPeer.new())
	multiplayer_data.is_multiplayer = false
	multiplayer_data.server_clear_players()
	
	_load_version()


func _load_version():
	var version = version_data.data.version
	var commit = version_data.data.commit
	
	_version_button.set_text(version + " [" + commit.substr(0, 10) + "]")


func _on_version_pressed():
	DisplayServer.clipboard_set(_version_button.get_text())
