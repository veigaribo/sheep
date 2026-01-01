extends VBoxContainer
class_name SaveButtons


@export_file var save_button_scene_path: String


func add_button(data: PackedByteArray):
	var children_count = get_child_count()
	
	var button := load(save_button_scene_path).instantiate() as SaveButton
	button.set_data(data)
	button.set_text(button.get_text() + " " + str(children_count + 1))
	
	add_child(button)
