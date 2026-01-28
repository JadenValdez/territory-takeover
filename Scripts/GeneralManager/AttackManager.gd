extends Node2D

signal set_attack_list
signal get_tile_info
signal get_player_info_attack

signal set_tile_attack_value

@onready var tile_manager: Node2D = $"../TileManager"
@onready var player_manager: Node2D = $"../PlayerManager"
@onready var conquest_phase: Node2D = $"../PhaseManager/ConquestPhase"
@onready var confirm_attack_button: Node2D = $"../UiManager/ButtonUI/ConfirmAttackButton"

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
var player_list = []
var attack_list = {}
var attack_list_confirmed = {}
var attack_list_send = {}
var default_attack_list = {}

var attacked_territory = [] 
var confirmed_territory = []
var searching_territory = []
var remaining_territory = []
var temp_territory_array = []
var remaining_attacks_search = []
var remaining_attacks = []
var temp_targets = []

var tile = {
	"ID": "00",
	"Owner": "None",
	"Status": "Empty",
	"Lives": 1,
	"Color": [0, 0, 0],
	"Neighbors": [],
	"Position": Vector2(0, 0)
	}
var neighbors = []

func _ready() -> void:
	player_manager.get_player_list_info.connect(_get_player_list_info)
	player_manager.set_current_player.connect(_set_current_player)
	player_manager.return_player_info_attack.connect(_return_player_info_attack)
	tile_manager.add_attack_count.connect(_add_attack_count)
	tile_manager.subtract_attack_count.connect(_subtract_attack_count)
	tile_manager.return_tile_info.connect(_return_tile_info)
	conquest_phase.get_attack_list.connect(_get_attack_list)
	confirm_attack_button.confirm_attack.connect(_confirm_attack)
		
func _input(event) -> void:
	if event.is_action_pressed("one"):
		pass
		
#put a function that resets the attack list at the start of a new conquest phase
		
func _get_player_list_info(player_list_info) -> void:
	for key in player_list_info:
		print(key)
		player_list.append(key)
		attack_list[key] = {}
		attack_list_confirmed[key] = {}
	default_attack_list = attack_list.duplicate(true)
	
func _set_current_player(player_info)  -> void:
	current_player = player_info
	print(attack_list[current_player["Name"]])
	emit_signal("set_tile_attack_value", attack_list[current_player["Name"]])
	
func _return_tile_info(tile_info) -> void:
	tile = tile_info
	
func _return_player_info_attack(player_info) -> void:
	_set_current_player(player_info)
	
func _add_attack_count(tile_name)  -> void:
	if attack_list[current_player["Name"]].has(tile_name):
		attack_list[current_player["Name"]][tile_name] += 1
	else:
		attack_list[current_player["Name"]][tile_name] = 1
		
func _subtract_attack_count(tile_name)  -> void:
	if attack_list[current_player["Name"]].has(tile_name):
		attack_list[current_player["Name"]][tile_name] -= 1
		if attack_list[current_player["Name"]][tile_name] <= 0:
			attack_list[current_player["Name"]].erase(tile_name)
	else:
		print("No attacks on this tile.")
		
func _confirm_attack() -> void:
	emit_signal("get_player_info_attack", current_player["Name"])
	#find a way to update the players territory after confirming attack
	attacked_territory = []
	for key in attack_list[current_player["Name"]]:
		attacked_territory.append(key)
	if _check_if_valid_attack():
		for key in attack_list[current_player["Name"]]:
			attack_list_confirmed[current_player["Name"]][key] = attack_list[current_player["Name"]][key]
		
func _check_if_valid_attack() -> bool:
	for c in current_player["Territory"]:
		for t in attacked_territory:
			if c == t:
				print("You cannot attack your own tiles.")
				return false
				
	remaining_attacks_search = attacked_territory.duplicate(true)
	
	remaining_territory = current_player["Territory"].duplicate(true)
	confirmed_territory = []
	searching_territory = [current_player["Base"]]
	remaining_territory.erase(current_player["Base"])
	remaining_territory.append_array(attacked_territory)
	temp_targets = []
	print(remaining_territory)
	print(searching_territory)
	#could use a while loop, but apparently its prone to errors
	for i in range(remaining_territory.size() + 1):
		if searching_territory == []:
			break
		confirmed_territory.append_array(searching_territory)
		
		if remaining_territory == []:
			break
		
		for s in searching_territory:
			emit_signal("get_tile_info", s)
			neighbors = _tile_neighbors()
			for n in neighbors:
				for r in remaining_territory:
					if n == r:
						temp_territory_array.push_back(r)
						for a in attacked_territory:
							if n == a:
								temp_targets.append(n)
								break
						break
				remaining_attacks_search.erase(n)
				remaining_territory.erase(n)

		searching_territory = temp_territory_array.duplicate(true)
		temp_territory_array.clear()
	if remaining_attacks_search.is_empty():
		#change this later
		#attacking_player_territory = confirmed_territory.duplicate(true)
		#_perform_attacks(temp_targets)
		#_update_territory(attacking_player_territory)
		print("Attack is Valid")
		return true
	else:
		print("Please ensure all attacks can be connected to your base through your tiles and/or other attacks.")
		return false
		
func _tile_neighbors() -> Array:
	return tile["Neighbors"].duplicate(true)
		
func _get_attack_list() -> void:
	attack_list_send = attack_list_confirmed.duplicate(true)
	emit_signal("set_attack_list", attack_list_send)
	attack_list_confirmed = default_attack_list.duplicate(true)
	attack_list = default_attack_list.duplicate(true)
	
