extends Button
class_name SaveButton


var data: PackedByteArray


func set_data(data: PackedByteArray):
	self.data = data


func _on_pressed() -> void:
	var path = "user://replay_" + str(Time.get_unix_time_from_system()) + ".sheep"
	var file = FileAccess.open(path, FileAccess.WRITE)
	
	if file:
		file.store_buffer(data.compress(FileAccess.COMPRESSION_ZSTD))
		file.close()
		print("Replay saved to: ", path)
	else:
		print("Failed to save file: ", FileAccess.get_open_error())
