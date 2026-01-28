extends Node2D

signal start_conquest

func _ready() -> void:
	pass # Replace with function body.

func _on_start_conquest_button_control_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				emit_signal("start_conquest")
