extends Node2D

signal get_player_info

@onready var general_info_label: Label = $GeneralInfoLabel
@onready var tile_manager: Node2D = $"../../TileManager"
@onready var player_manager: Node2D = $"../../PlayerManager"

var player_list = [
	#[Player, Action]
	[ "Player", "z"],
	[ "Enemy" , "x"], 
	[ "Rival" , "c"]
	]

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
var current_player_name = "None"
var current_player_base = "00"
var current_player_territory = []
var current_player_color = [1, 1, 1]
var current_player_stats = {
		"Attack": 1,
		"Defense": 1,
		"Energy": 1,
		"Speed": 1,
		"Technology": 1,
		"Luck": 1,
		}
var current_player_coins = 0
var current_player_inventory = {
		"Buildings" : {},
		"Boosts" : {},
		"Conquest" : {},
		"Misc." : {}
		}

func _ready() -> void:
	tile_manager.initialize_ui.connect(_initialize_ui)
	player_manager.set_current_player.connect(_set_current_player)

func _set_current_player(player_info) -> void: 
	_return_player_info(player_info)
	_initialize_ui()

func _get_player_info() -> void: 
	emit_signal("get_player_info", current_player)

func _return_player_info(player_info) -> void: 
	current_player = player_info
	current_player_name = player_info["Name"]
	current_player_base = player_info["Base"]
	current_player_territory = player_info["Territory"]
	current_player_color = player_info["Color"]
	current_player_stats = player_info["Stats"]

func _initialize_ui() -> void:
	general_info_label.text = ("Current Player: " + current_player_name)
	general_info_label.modulate = Color(current_player_color[0], current_player_color[1], current_player_color[2])
