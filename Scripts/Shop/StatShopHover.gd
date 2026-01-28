extends Node2D

signal show_stat_tooltip
signal hide_stat_tooltip

var stat_name = "Stat"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _on_control_mouse_entered() -> void:
	emit_signal("show_stat_tooltip", stat_name)

func _on_control_mouse_exited() -> void:
	emit_signal("hide_stat_tooltip", stat_name)
