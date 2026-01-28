extends Node2D

signal animate_attack
signal finished_attack_animation
signal end_attack_animation
signal continue_coin_flips

#@onready var coin = preload("res://Scenes/Conquest/Coin.tscn")
@onready var conquest_phase: Node2D = $"../../PhaseManager/ConquestPhase"
@onready var main_camera: Camera2D = $"../../MainCamera"
@onready var coin_flip_background: ColorRect = $CoinFlipBackground
@onready var player_one_label: Label = $DuelPlayerOne/PlayerOneLabel
@onready var player_two_label: Label = $DuelPlayerTwo/PlayerTwoLabel
@onready var duel_player_one: Polygon2D = $DuelPlayerOne
@onready var duel_player_two: Polygon2D = $DuelPlayerTwo
@onready var attack_bar: Node2D = $AttackBar
@onready var attack_bar_attacker: ColorRect = $AttackBar/AttackBarAttacker
@onready var attack_bar_defender: ColorRect = $AttackBar/AttackBarDefender
@onready var player_one_attack_value_label: Label = $DuelPlayerOne/PlayerOneAttackValueLabel
@onready var player_two_defense_value_label: Label = $DuelPlayerTwo/PlayerTwoDefenseValueLabel



var attacker_color = [0, 0, 0]
var defender_color = [0, 0, 0]
var current_tile_attack = 0
var xpos = 0.0

func _ready() -> void:
	conquest_phase.start_attack_sequence.connect(_start_attack_sequence)
	conquest_phase.create_attack_animation.connect(_create_attack_animation)
	conquest_phase.animate_attack.connect(_animate_attack)
	conquest_phase.end_attack_animation.connect(_end_attack_animation)
	conquest_phase.end_attack_sequence.connect(_end_attack_sequence)
	conquest_phase.attacking_neutral_tile.connect(_attacking_neutral_tile)
	attack_bar.finished_attack_animation.connect(_finished_attack_animation)
	
func _start_attack_sequence(attacking_player_name, attacking_player_color) -> void:
	player_one_label.text = attacking_player_name
	player_one_label.modulate = Color(attacking_player_color[0], attacking_player_color[1], attacking_player_color[2])
	duel_player_one.visible = true
	
func _end_attack_sequence() -> void:
	duel_player_one.visible = false
	duel_player_two.visible = false
	
func _attacking_neutral_tile() -> void:
	duel_player_two.visible = false
	
func _create_attack_animation(attacking_player_name, attacking_player_color, defending_player_name, defending_player_color, attacker_ATK, defender_DEF, total_stats, advantage) -> void:
	#coin_flip_background.position = Vector2(-600, -50)
	#coin_flip_background.visible = true
	duel_player_two.visible = true
	
	player_one_label.text = attacking_player_name
	player_two_label.text = defending_player_name
	player_one_attack_value_label.text = str(attacker_ATK)
	player_two_defense_value_label.text = str(defender_DEF)
	
	attacker_color = attacking_player_color.duplicate(true)
	defender_color = defending_player_color.duplicate(true)
	player_one_label.modulate = Color(attacker_color[0], attacker_color[1], attacker_color[2])
	player_two_label.modulate = Color(defender_color[0], defender_color[1], defender_color[2])
	player_one_attack_value_label.modulate = Color(attacker_color[0], attacker_color[1], attacker_color[2])
	player_two_defense_value_label.modulate = Color(defender_color[0], defender_color[1], defender_color[2])
	
	player_one_attack_value_label.visible = true
	player_two_defense_value_label.visible = true
	
	attack_bar.visible = true
	attack_bar_attacker.modulate = Color(attacker_color[0], attacker_color[1], attacker_color[2])
	attack_bar_defender.modulate = Color(defender_color[0], defender_color[1], defender_color[2])
	
	if advantage == "Attacker":
		attack_bar_attacker.size = Vector2(((total_stats - 1.0) / total_stats) * 600, 32)
		attack_bar_defender.size = Vector2((1.0 / total_stats) * 600, 32)
		attack_bar_defender.position = Vector2((total_stats - 1.0) / total_stats * 600 + 8.0, 8.0)
	else:
		attack_bar_attacker.size = Vector2(1.0 / total_stats * 600 , 32)
		attack_bar_defender.size = Vector2((total_stats - 1.0)/ total_stats * 600, 32)
		attack_bar_defender.position = Vector2(1.0 / total_stats * 600 + 8.0, 8.0)
	
	#for t in total_tile_attacks:
		#current_tile_attack = t + 1
		#if total_stats == 2:
			#var instance = coin.instantiate()
			#instance.attacker_color = attacking_player_color
			#instance.defender_color = defending_player_color
			#instance.self_attack_num = current_tile_attack
			
			#if current_tile_attack >= 2:
				#instance.position = Vector2(575 + (current_tile_attack * 50), 300)
				#instance.scale = Vector2(1, 1)
			#else:
				#instance.position = Vector2(575, 300)
				#instance.scale = Vector2(2, 2)
			
			#instance.finished_attack_animation.connect(_finished_attack_animation) 
			#instance.continue_coin_flips.connect(_continue_coin_flips)
			#add_child(instance)
		#else:
			#print("what")
	

func _animate_attack(winner, attack_num, attack_result, total_stats_count) -> void:
	if winner == "Attacker":
		emit_signal("animate_attack", attacker_color, attack_num, attack_result, total_stats_count)
	else: 
		emit_signal("animate_attack", defender_color, attack_num, attack_result, total_stats_count)
	
	
	
	
func _end_attack_animation(result) -> void:
	#coin_flip_background.position = Vector2(0, 5000)
	coin_flip_background.visible = false
	attack_bar.visible = false
	player_one_attack_value_label.visible = false
	player_two_defense_value_label.visible = false
	emit_signal("end_attack_animation", result)

func _finished_attack_animation() -> void:
	emit_signal("finished_attack_animation")
	
func _continue_coin_flips() -> void:
	emit_signal("continue_coin_flips")
