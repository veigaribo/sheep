class_name RNG
extends Node


var rand := RandomNumberGenerator.new()


func _ready() -> void:
	randomize()


func randomize():
	rand.randomize()


func get_seed() -> int:
	return rand.get_seed()
