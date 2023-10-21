extends CheckButton


@onready var container := $'../AdvancedContainer' as VBoxContainer


func _on_toggled(button_pressed):
	container.set_visible(button_pressed)
