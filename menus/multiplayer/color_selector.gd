class_name ColorSelector
extends HBoxContainer

signal color_changed(color: Color)
signal color_changed_debounced(color: Color)

var _last_color: Color

@onready var _debouncer = $Debouncer
@onready var _button = $ColorPickerButton


func _ready():
	var picker := _button.get_picker() as ColorPicker
	picker.set_picker_shape(ColorPicker.SHAPE_VHS_CIRCLE)
	picker.set_can_add_swatches(false)
	picker.set_presets_visible(false)
	picker.set_sampler_visible(false)
	picker.set_sliders_visible(false)
	picker.set_hex_visible(false)
	picker.set_modes_visible(false)
	
	var popup := _button.get_popup() as PopupPanel
	popup.set_transparent_background(true)
	popup.set_content_scale_factor(0.5)
	
	# https://github.com/godotengine/godot/issues/83875
	popup.set_wrap_controls(false)


func get_pick_color() -> Color:
	return _button.get_pick_color()


func set_pick_color(color: Color):
	_button.set_pick_color(color)


func _on_color_picker_color_changed(color):
	color_changed.emit(color)
	_last_color = color
	_debounce()


func _debounce():
	_debouncer.start()


func _on_debouncer_timeout():
	color_changed_debounced.emit(_last_color)


func _on_color_picker_toggled(button_pressed):
	if button_pressed:
		_position_popup.call_deferred()


func _position_popup():
	var popup := _button.get_popup() as PopupPanel
	popup.set_position(Vector2i(85, 30))
	popup.set_size(Vector2i(150, 130))
