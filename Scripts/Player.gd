extends Node2D

var player = {
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
	"Stat Boosts": {
		"Attack": 0,
		"Defense": 0,
		"Energy": 0,
		"Speed": 0,
		"Technology": 0,
		"Luck": 0,
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
var player_name = "None"
var base_location = "00"
var territory = []
var color = [1, 1, 1]

var stats = {
		"Attack": 1,
		"Defense": 1,
		"Energy": 1,
		"Speed": 1,
		"Technology": 1,
		"Luck": 1,
		}
#var stat_attack = 1
#var stat_defense = 1
#var stat_energy = 1
#var stat_speed = 1
#var stat_technology = 1
#var stat_luck = 1
var previous_speed = 1

var coins = 0
var inventory = {
	"Buildings" : {},
	"Boosts" : {},
	"Conquest" : {},
	"Misc." : {}
	}
	
var stat_boosts = {
	"Attack": 0,
	"Defense": 0,
	"Energy": 0,
	"Speed": 0,
	"Technology": 0,
	"Luck": 0,
	}
var action = ""
var status = "Alive"

@onready var player_manager: Node2D = $".."

signal set_current_player
signal return_player_info_ui
signal return_player_info_conquest
signal return_player_info_attack

signal update_player_order



func _ready() -> void:
	player_manager.update_territory.connect(_update_territory)
	player_manager.get_player_info_ui.connect(_get_player_info_ui)
	player_manager.get_player_info_conquest.connect(_get_player_info_conquest)
	player_manager.update_player_shop.connect(_update_player_shop)
	player_manager.get_player_info_attack.connect(_get_player_info_attack)
	player_manager.player_defeated.connect(_player_defeated)

	
func _input(event) -> void:
	if event.is_action_pressed(action):
		print(player_name)
		emit_signal("set_current_player", player)
		
func _update_profile() -> void:
	player = {
	"Name": player_name, 
	"Base": base_location, 
	"Territory": territory, 
	"Color": color, 
	"Stats": stats, 
	"Stat Boosts": stat_boosts,
	"Coins": coins, 
	"Inventory": inventory,
	"Status": status
	}
		
func _update_territory(current_player_name, terr) -> void:
	if current_player_name == player_name:
		territory = terr
		_update_profile()

func _get_player_info_ui(player_info) -> void:
	if player_name == player_info:
		emit_signal("return_player_info_ui", player)

func _get_player_info_conquest(player_info) -> void:
	if player_name == player_info:
		emit_signal("return_player_info_conquest", player)
		
func _get_player_info_attack(player_info) -> void:
	if player_name == player_info:
		emit_signal("return_player_info_attack", player)
		
func _update_player_shop(player_name_shop, current_stats, current_coins, current_inventory) -> void:
	if player_name_shop == player_name:
		stats = current_stats.duplicate(true)
		coins = current_coins
		inventory = current_inventory.duplicate(true)
		_update_profile()
		if previous_speed != player["Stats"]["Speed"]:
			emit_signal("update_player_order", player["Name"], player["Stats"]["Speed"])
			previous_speed = player["Stats"]["Speed"]
		
func _update_player_inventory(player_info, inventory_update):
	if player_name == player_info:
		inventory = inventory_update.duplicate(true)
		_update_profile()

func _player_defeated(player_info, winner):
	if player_name == player_info:
		base_location = "00"
		territory = []
		color = [0.5, 0.5, 0.5]
		stats = {
		"Attack": 0,
		"Defense": 0,
		"Energy": 0,
		"Speed": 0,
		"Technology": 0,
		"Luck": 0,
		}
		status = "Dead"
		emit_signal("update_player_order", player["Name"], 0)
		_update_profile()
		#add some other things
