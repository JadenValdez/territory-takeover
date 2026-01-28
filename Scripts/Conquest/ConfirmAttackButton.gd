extends Node2D

signal confirm_attack

func _ready() -> void:
	pass 

func _on_confirm_attack_button_control_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				emit_signal("confirm_attack")
