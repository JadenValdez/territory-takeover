extends Node2D
signal choose_tile
var id = "00"

func _on_button_pressed() -> void:
	emit_signal("choose_tile", "A3")
	pass # Replace with function body.
