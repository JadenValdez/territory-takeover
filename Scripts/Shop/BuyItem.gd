extends Node2D

signal buy_item

func _ready() -> void:
	pass # Replace with function body.

func _on_buy_item_control_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				emit_signal("buy_item")
