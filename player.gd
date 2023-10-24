class_name Player
extends RefCounted

var multiplayer_id: int
var name: String
var color: Color


func _init(multiplayer_id: int, name: String, color: Color):
	self.name = name
	self.multiplayer_id = multiplayer_id
	self.color = color
