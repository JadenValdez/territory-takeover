extends Node2D



@onready var tile_manager: Node2D = $"../TileManager"
@onready var player = preload("res://Scenes/Player.tscn")
@onready var phase_manager: Node2D = $"../PhaseManager"
@onready var conquest_phase: Node2D = $"../PhaseManager/ConquestPhase"
@onready var general_info: Node2D = $"../UiManager/GeneralInfo"
@onready var shop_ui: Node2D = $"../UiManager/ShopUI"
@onready var attack_manager: Node2D = $"../AttackManager"
@onready var inventory: Node2D = $"../UiManager/Inventory"

var player_list = {
	"Player": {"Base": "B1", "Color": [0, 0, 1], "Icon": "res://Assests/Icons/icon.svg", "Action": "z"},
	"Enemy": {"Base": "F9", "Color": [1, 0, 0], "Icon": "res://Assests/Icons/icon.svg", "Action": "x"},
	"Rival": {"Base": "I4", "Color": [0, 1, 0], "Icon": "res://Assests/Icons/icon.svg", "Action": "c"},
	"Ghost": {"Base": "E5", "Color": [1, 0, 1], "Icon": "res://Assests/Icons/Ghost256.jpg", "Action": "v"}
	}

#var default_player = player_list[0]
signal get_player_list_info
signal set_current_player
signal update_territory

signal get_player_info_ui
signal get_player_info_conquest
signal return_player_info_ui
signal return_player_info_conquest
signal get_player_info_attack
signal return_player_info_attack

signal update_player_shop

signal get_player_speed
signal set_player_order
signal update_player_order
signal set_bases
signal create_player_tabs
signal setup_tile_selections

signal update_player_inventory

signal update_base_lives
signal player_defeated

var current_player = {
	"Name": "None", 
	"Base": "00", 
	"Territory": [], 
	"Color": [1, 1, 1], 
	"Stats": {
		"Attack": 1,
		"Defense": 1,
		"Energy": 1,
		"Speed": 1,
		"Technology": 1,
		"Luck": 1,
		}, 
	"Coins": 0, 
	"Inventory": {
		"Buildings" : {},
		"Boosts" : {},
		"Conquest" : {},
		"Misc." : {}
		},
	"Status": "Alive"
	}
var current_phase = "None"
	
var player_color = [0, 0, 1]
var tile_id = "A1"

var player_order = []
var player_order_speed = {}

func _ready() -> void:
	tile_manager.choose_tile.connect(_set_target)
	phase_manager.set_current_phase.connect(_set_current_phase)
	conquest_phase.update_territory.connect(_update_territory)
	shop_ui.update_player_shop.connect(_update_player_shop)
	
	general_info.get_player_info.connect(_get_player_info_ui)
	conquest_phase.get_player_info.connect(_get_player_info_conquest)
	attack_manager.get_player_info_attack.connect(_get_player_info_attack)
	
	tile_manager.update_base_lives.connect(_update_base_lives)
	tile_manager.player_defeated.connect(_player_defeated)

	#waits for everything to load
	await get_tree().create_timer(0.25).timeout
	_create_lobby()
	#print(default_player)
	#_set_current_player(default_player)
	
		
func _create_lobby() -> void:
	for key in player_list:
		_create_player(key, player_list[key]["Base"], [player_list[key]["Base"]], player_list[key]["Color"], player_list[key]["Action"])
		player_order.append(key)
		player_order_speed[key] = 1
	emit_signal("set_bases", player_list)
	emit_signal("get_player_list_info", player_list)
	emit_signal("set_player_order", player_order, player_order_speed)
	emit_signal("create_player_tabs", player_list, player_order)
	emit_signal("setup_tile_selections", player_order)
	
func _create_player(player_name, location, territory, color, action) -> void:
	var instance = player.instantiate()
	instance.player_name = player_name
	instance.base_location = location
	instance.territory = territory
	instance.color = color
	instance.stats = {
		"Attack": 1,
		"Defense": 1,
		"Energy": 1,
		"Speed": 1,
		"Technology": 1,
		"Luck": 1,
		}
	instance.stat_boosts = {
		"Attack": 0,
		"Defense": 0,
		"Energy": 0,
		"Speed": 0,
		"Technology": 0,
		"Luck": 0,
		}
	instance.coins = 4000
	instance.inventory = {
	"Buildings" : {},
	"Boosts" : {},
	"Conquest" : {},
	"Misc." : {}
	}
	instance.status = "Alive"
	
	instance.player = {
	"Name": player_name, 
	"Base": location, 
	"Territory": territory, 
	"Color": color, 
	"Stats": {
		"Attack": 1,
		"Defense": 1,
		"Energy": 1,
		"Speed": 1,
		"Technology": 1,
		"Luck": 1,
		}, 
	"Stat Boosts": {
		"Attack": 0,
		"Defense": 0,
		"Energy": 0,
		"Speed": 0,
		"Technology": 0,
		"Luck": 0,
		},
	"Coins": 4000, 
	"Inventory": {
		"Buildings" : {},
		"Boosts" : {},
		"Conquest" : {},
		"Misc." : {}
		},
	"Status": "Alive"
	}
	
	instance.action = action
	instance.set_current_player.connect(_set_current_player)
	instance.return_player_info_ui.connect(_return_player_info_ui)
	instance.return_player_info_conquest.connect(_return_player_info_conquest)
	instance.return_player_info_attack.connect(_return_player_info_attack)
	instance.update_player_order.connect(_update_player_order)
	
	add_child(instance)
	
func _set_target(target_id) -> void:
	tile_id = target_id
	
func _set_current_player(c_player)  -> void:
	current_player = c_player
	emit_signal("set_current_player", current_player)
	
func _set_current_phase(phase)  -> void:
	current_phase = phase
	
func _update_territory(current_player_name, terr) -> void:
	emit_signal("update_territory", current_player_name, terr)
	
func _get_player_info_ui(player_name) -> void:
	emit_signal("get_player_info_ui", player_name)
	
func _return_player_info_ui(player_info) -> void:
	emit_signal("return_player_info_ui", player_info)
	
func _get_player_info_conquest(player_name) -> void:
	emit_signal("get_player_info_conquest", player_name)
	
func _return_player_info_conquest(player_info) -> void:
	emit_signal("return_player_info_conquest", player_info)
	
func _get_player_info_attack(player_name) -> void:
	emit_signal("get_player_info_attack", player_name)

func _return_player_info_attack(player_info) -> void:
	emit_signal("return_player_info_attack", player_info)

func _update_player_shop(player_name, current_stats, current_coins, current_inventory) -> void:
	emit_signal("update_player_shop", player_name, current_stats, current_coins, current_inventory)
	
func _update_player_order(player_name, player_speed) -> void:
	emit_signal("update_player_order", player_name, player_speed)
	
func _update_player_inventory(player_name, player_inventory) -> void:
	emit_signal("update_player_inventory", player_name, player_inventory)
	
func _player_defeated(player_name, winner) -> void:
	emit_signal("player_defeated", player_name, winner)

func _update_base_lives(player_name, base_lives) -> void:
	emit_signal("update_base_lives", player_name, base_lives)
