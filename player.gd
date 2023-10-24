class_name Player
extends RefCounted


enum States {
	IN_LOBBY,
	PLAYING,
}


var multiplayer_id: int
var name: String
var color: Color
var state: States = States.IN_LOBBY


func _init(multiplayer_id: int, name: String, color: Color):
	self.name = name
	self.multiplayer_id = multiplayer_id
	self.color = color
