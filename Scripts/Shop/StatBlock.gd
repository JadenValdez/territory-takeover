extends Node2D

@onready var stat_block_fill: ColorRect = $StatBlockFill
@onready var shop_ui: Node2D = $".."

var stat_name_id = "Stat"
var block_placement = 1
var current_value = 0

func _ready() -> void:
	shop_ui.set_stats.connect(_set_stats)
	shop_ui.set_potential_stats.connect(_set_potential_stats)
	
func _set_stats(stat_name, stat_value) -> void:
	if stat_name == stat_name_id:
		stat_block_fill.self_modulate.a = 1
		current_value = stat_value
		_set_color(stat_value)
			
func _set_potential_stats(stat_name, stat_value) -> void:
	if stat_name == stat_name_id:
		stat_block_fill.self_modulate.a = 1
		if stat_value - current_value >= 5:
			stat_block_fill.self_modulate.a = 0.5
			pass
		else:
			for s in range(stat_value - current_value):
				if posmod(posmod(current_value - 1, 5) + s + 1, 5) + 1 == block_placement:
					stat_block_fill.self_modulate.a = 0.5
					#print("blokc:" + str(block_placement))
					pass
		_set_color(stat_value)
	
func _set_color(stat_value):
	if stat_value >= 15 + block_placement:
		stat_block_fill.modulate = Color(1, 0, 0) #red
		
	elif stat_value >= 10 + block_placement:
		stat_block_fill.modulate = Color(1, 0, 1) #purple

	elif stat_value >= 5 + block_placement:
		stat_block_fill.modulate = Color(0, 0.5, 1) #blue

	elif stat_value >= block_placement:
		stat_block_fill.modulate = Color(1, 1, 0) #yellow

	elif stat_value <= 0 - block_placement:
		stat_block_fill.modulate = Color(1, 0, 0) #red

	else:
		stat_block_fill.modulate = Color(0, 0, 0) #black
	
