extends Node2D

signal check_if_can_add_buy
signal check_if_can_subtract_buy
signal show_next_stat_preview
signal hide_next_stat_preview

var stat_name = "Stat"

func _ready() -> void:
	pass # Replace with function body.

func _on_plus_button_control_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				_add_stats_buy()
				emit_signal("show_next_stat_preview", stat_name, "Buy")

func _on_minus_button_control_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				_subtract_stats_buy()
				emit_signal("show_next_stat_preview", stat_name, "Sell")
				
func _on_plus_button_control_mouse_entered() -> void:
	emit_signal("show_next_stat_preview", stat_name, "Buy")
	
func _on_minus_button_control_mouse_entered() -> void:
	emit_signal("show_next_stat_preview", stat_name, "Sell")

func _on_plus_button_control_mouse_exited() -> void:
	emit_signal("hide_next_stat_preview")
	
func _on_minus_button_control_mouse_exited() -> void:
	emit_signal("hide_next_stat_preview")

func _add_stats_buy() -> void:
	emit_signal("check_if_can_add_buy", stat_name)
	
func _subtract_stats_buy() -> void:
	emit_signal("check_if_can_subtract_buy", stat_name)
