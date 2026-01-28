extends Node2D

signal finished_attack_animation

@onready var attack_cursor_label: Label = $AttackCursorLabel
@onready var attack_cursor_background: ColorRect = $AttackCursorBackground
@onready var attack_cursor_background_bottom: Polygon2D = $AttackCursorBackgroundBottom
@onready var attack_cursor_background_top: Polygon2D = $AttackCursorBackgroundTop
@onready var attack_bar: Node2D = $".."

var attack_num = 0
var xpos = 0.0
var target = Vector2(0, 0)
var moving = true
var winner_color = [0, 0, 0]

func _ready() -> void:
	attack_bar.end_attack_animation.connect(_end_attack_animation)
	attack_cursor_label.text = str(attack_num)
	if attack_num % 2 == 1:
		target = Vector2(xpos * 600, -20)
		attack_cursor_background_bottom.visible = true
		position = Vector2(0, -20)
	else:
		target = Vector2(xpos * 600, 50)
		attack_cursor_background_top.visible = true
		position = Vector2(0, 50)
		
func _end_attack_animation() -> void:
	queue_free()
	
func _process(delta: float) -> void:
	if moving:
		if (position - target) > Vector2(1, 0):
			position = target
			attack_cursor_background.modulate = Color(winner_color[0], winner_color[1], winner_color[2])
			attack_cursor_background_bottom.modulate = Color(winner_color[0], winner_color[1], winner_color[2])
			attack_cursor_background_top.modulate = Color(winner_color[0], winner_color[1], winner_color[2])
			moving = false
			emit_signal("finished_attack_animation")
		else:
			position += Vector2(600 * delta, 0)
	
