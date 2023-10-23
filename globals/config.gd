class_name SheepConfig
extends Node


@onready var config_file := ConfigFile.new()


func set_default_multiplayer_name(name: String):
	config_file.set_value("multiplayer", "default_name", name)


func get_default_multiplayer_name():
	return config_file.get_value("multiplayer", "default_name")


func set_default_multiplayer_host_port(port: int):
	config_file.set_value("multiplayer", "default_host_port", port)


func get_default_multiplayer_host_port():
	return config_file.get_value("multiplayer", "default_host_port")


func set_default_multiplayer_host_max_players(count: int):
	config_file.set_value("multiplayer", "default_host_max_players", count)


func get_default_multiplayer_host_max_players():
	return config_file.get_value("multiplayer", "default_host_max_players")


func set_default_multiplayer_host_ip_addr(addr: String):
	config_file.set_value("multiplayer", "default_host_ip_addr", addr)


func get_default_multiplayer_host_ip_addr():
	return config_file.get_value("multiplayer", "default_host_ip_addr")


func set_default_multiplayer_connect_addr(addr: String):
	config_file.set_value("multiplayer", "default_connect_addr", addr)


func get_default_multiplayer_connect_addr():
	return config_file.get_value("multiplayer", "default_connect_addr")


func set_default_multiplayer_connect_port(port: int):
	config_file.set_value("multiplayer", "default_connect_port", port)


func get_default_multiplayer_connect_port():
	return config_file.get_value("multiplayer", "default_connect_port")


func load():
	config_file.load("user://config.cfg")


func persist():
	config_file.save("user://config.cfg")
