extends Node2D

var player_name = "None"
var player_color = [0, 0, 0]
var player_speed = 1
var player_icon = ""
var pos = Vector2(0,0)

var sprite_load

@onready var player_order: Node2D = $".."
@onready var player_order_tab_background: Polygon2D = $PlayerOrderTabBackground
@onready var player_order_tab_name: Label = $PlayerOrderTabName
@onready var player_order_tab_speed_num: Label = $PlayerOrderTabSpeedNum
@onready var player_order_tab_icon: Sprite2D = $PlayerOrderTabIcon
@onready var player_lives: Label = $PlayerLives

func _ready() -> void:
	player_order_tab_background.modulate = Color(player_color[0], player_color[1], player_color[2])
	player_order_tab_name.text = player_name
	player_order_tab_speed_num.text = str(player_speed)
	sprite_load = load(player_icon)
	player_order_tab_icon.texture = sprite_load
	
	player_order.update_base_lives.connect(_update_base_lives)
	player_order.player_defeated.connect(_player_defeated)
	
	position = pos
	
	player_order.update_order_tabs.connect(_update_order_tabs)

func _update_order_tabs(p_name, speed, target) -> void:
	if p_name == player_name:
		pos = target
		player_speed = speed
		player_order_tab_speed_num.text = str(player_speed)
		
func _update_base_lives(p_name, base_lives) -> void:
	if p_name == player_name:
		if base_lives <= 3:
			player_lives.text = str(base_lives)
			player_lives.visible = true
			if base_lives == 2:
				player_lives.modulate = Color(1, 0.5, 0)
			elif base_lives == 1:
				player_lives.modulate = Color(1, 0, 0)
		
func _player_defeated(p_name, _winner) -> void:
	if p_name == player_name:
		player_order_tab_background.modulate = Color(0.5, 0.5, 0.5)
		player_lives.visible = false

func _process(_delta: float) -> void:
	position = position.lerp(pos, 0.15)
