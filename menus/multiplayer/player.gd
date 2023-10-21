class_name Player
extends RefCounted

var name: String
var multiplayer_id: int


func _init(multiplayer_id: int, name: String):
	self.name = name
	self.multiplayer_id = multiplayer_id
