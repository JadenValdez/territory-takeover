extends Node2D

signal reset_stats_shop

@onready var reset_stats_control: Control = $ResetStatsControl
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _on_reset_stats_control_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				emit_signal("reset_stats_shop")
