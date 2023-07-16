class_name RNG
extends Node


var rand := RandomNumberGenerator.new()
	

func _ready() -> void:
	rand.randomize()
