class_name CountCorralled
extends Label


func _ready() -> void:
	set_text("0")


func _on_corralled(total: int) -> void:
	set_text(str(total))
