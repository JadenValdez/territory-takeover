extends Node2D

signal finished_attack_animation
signal end_attack_animation

@onready var battle_ui: Node2D = $".."
const ATTACK_CURSOR = preload("res://Scenes/Conquest/AttackCursor.tscn")

var rng = RandomNumberGenerator.new()
var xpos = 0.0

func _ready() -> void:
	battle_ui.animate_attack.connect(_animate_attack)
	battle_ui.end_attack_animation.connect(_end_attack_animation)
	
func _animate_attack(winner_color, attack_num, attack_result, total_stats_count) -> void:
	var instance_ATTACK_CURSOR = ATTACK_CURSOR.instantiate()
	instance_ATTACK_CURSOR.scale = Vector2(0.3, 0.3)
	
	instance_ATTACK_CURSOR.attack_num = attack_num
	
	xpos = (rng.randf() / total_stats_count) + ((float(attack_result) - 1.0) / total_stats_count)
	instance_ATTACK_CURSOR.xpos = xpos
	instance_ATTACK_CURSOR.winner_color = winner_color
		
	instance_ATTACK_CURSOR.finished_attack_animation.connect(_finished_attack_animation) 
	
	add_child(instance_ATTACK_CURSOR)
	
func _end_attack_animation(_result) -> void:
	emit_signal("end_attack_animation")
	
func _finished_attack_animation() -> void:
	emit_signal("finished_attack_animation")
