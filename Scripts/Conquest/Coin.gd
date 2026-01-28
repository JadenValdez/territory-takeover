extends Node2D

signal finished_attack_animation
signal continue_coin_flips

@onready var coin_sprite: AnimatedSprite2D = $CoinSprite
@onready var battle_ui: Node2D = $".."

var attacker_color = [1, 1, 1]
var defender_color = [1, 1, 1]
var current_color = "Defender"
var self_attack_num = 0
var current_attack_num = 0
var flips = 0

var moving = false
var final_position = Vector2(0, 0) 
var final_scale = Vector2(1, 1) 

func _ready() -> void:
	moving = false
	coin_sprite.modulate = Color(1, 1, 1)
	#battle_ui.animate_attack.connect(_animate_attack)
	#battle_ui.end_attack_animation.connect(_end_attack_animation)
	
func _animate_attack(winner, attack_num) -> void:
	current_attack_num = attack_num
	if attack_num >= 2:
		_move_coins(attack_num)
		await battle_ui.continue_coin_flips
	#await get_tree().create_timer(0.2).timeout
	if attack_num == self_attack_num:
		if winner == "Attacker":
			flips = 3
		elif winner == "Defender":
			flips = 4
		coin_sprite.play("Coin Flip 1")
	
func _move_coins(attack_num) -> void:
	if attack_num == self_attack_num:
		final_position = position + Vector2(-100, 0)
		final_scale = Vector2(2, 2)
	elif attack_num == self_attack_num + 1:
		final_position = position + Vector2(-100, 0)
		final_scale = Vector2(1, 1)
	else:
		final_position = position + Vector2(-50, 0)
	moving = true
	
func _end_attack_animation(_result) -> void:
	queue_free()

func _on_coin_sprite_animation_finished() -> void:
	if coin_sprite.animation == "Coin Flip 1":
		coin_sprite.play("Coin Flip 2")
		if current_color == "Defender":
			current_color = "Attacker"
			coin_sprite.modulate = Color(attacker_color[0], attacker_color[1], attacker_color[2])
		else:
			current_color = "Defender"
			coin_sprite.modulate = Color(defender_color[0], defender_color[1], defender_color[2])
	elif coin_sprite.animation == "Coin Flip 2":
		flips -= 1
		if flips > 0:
			coin_sprite.play("Coin Flip 1")
		else:
			emit_signal("finished_attack_animation")
			
func _process(_delta: float) -> void:
	if moving:
		position = position.lerp(final_position, 0.5)
		scale = scale.lerp(final_scale, 0.4)
		if abs(position - final_position) < Vector2(0.1, 0.1):
			position = final_position
			scale = final_scale
			moving = false
			if current_attack_num == self_attack_num:
				emit_signal("continue_coin_flips")
