extends Node2D

signal update_order_tabs

signal update_base_lives
signal player_defeated

@onready var player_manager: Node2D = $"../../PlayerManager"
@onready var conquest_phase: Node2D = $"../../PhaseManager/ConquestPhase"

const PLAYER_ORDER_TAB = preload("res://Scenes/Conquest/PlayerOrderTab.tscn")

func _ready() -> void:
	player_manager.create_player_tabs.connect(_create_player_tabs)
	conquest_phase.set_player_order.connect(_set_player_order)
	player_manager.update_base_lives.connect(_update_base_lives)
	player_manager.player_defeated.connect(_player_defeated)

func _create_player_tabs(player_list, player_order) -> void:
	for n in player_order:
		var instance_PLAYER_ORDER_TAB = PLAYER_ORDER_TAB.instantiate()
		instance_PLAYER_ORDER_TAB.player_name = n
		instance_PLAYER_ORDER_TAB.player_color = player_list[n]["Color"]
		instance_PLAYER_ORDER_TAB.player_speed = 1
		instance_PLAYER_ORDER_TAB.player_icon = player_list[n]["Icon"]
		instance_PLAYER_ORDER_TAB.pos = Vector2(0, player_order.find(n) * 80)
		instance_PLAYER_ORDER_TAB.scale = Vector2(1, 1)
		
		add_child(instance_PLAYER_ORDER_TAB)
		
func _set_player_order(player_order, player_order_speed) -> void:
	for n in player_order:
		emit_signal("update_order_tabs", n, player_order_speed[n], Vector2(0, player_order.find(n) * 80))

func _update_base_lives(player_name, base_lives) -> void:
	emit_signal("update_base_lives", player_name, base_lives)

func _player_defeated(player_name, winner) -> void:
	emit_signal("player_defeated", player_name, winner)
