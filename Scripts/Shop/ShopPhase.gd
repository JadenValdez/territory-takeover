extends Node2D

signal get_player_info

func _ready() -> void:
	_set_up_stats()

func _set_up_stats() -> void:
	emit_signal("get_player_info")
	
func _set_up_items() -> void:
	pass
