extends HSlider


var _bus := AudioServer.get_bus_index("Master")


func _ready() -> void:
	value = db_to_linear(AudioServer.get_bus_volume_db(_bus))


func _on_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(_bus, linear_to_db(value))
