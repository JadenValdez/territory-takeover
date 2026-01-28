extends Node2D

signal get_tile_info
signal get_tile_attacks
signal attack_tile
signal attack_tile_failed
signal clear_target_list
signal update_territory
signal get_player_info
signal create_attack_animation
signal animate_attack
signal update_tile_lives
signal end_attack_animation
signal attacking_neutral_tile
signal start_attack_sequence
signal end_attack_sequence
signal set_lives
signal update_attacking_player_conquest

signal get_attack_list
signal set_tile_attack_value
signal set_tile_already_attacked
signal set_player_order

var attack_list = {}
var targets = []
var temp_targets = []
var already_target = false
var current_target = "00"

var player_list = []

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
	"Coins": 0, 
	"Inventory": {
		"Buildings" : {},
		"Boosts" : {},
		"Conquest" : {},
		"Misc." : {}
		},
	"Status": "Alive"
		
	}

var attacking_player_conquest = {
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
var attacking_player_name = "None"
var attacking_player_base = "00"
var attacking_player_territory = []
var attacking_player_color = [1, 1, 1]
var attacking_player_stats = {
		"Attack": 1,
		"Defense": 1,
		"Energy": 1,
		"Speed": 1,
		"Technology": 1,
		"Luck": 1,
		}

var defending_player_conquest = {
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
		}
	}
var defending_player_name = "None"
var defending_player_base = "00"
var defending_player_territory = []
var defending_player_color = [1, 1, 1]
var defending_player_stats = {
		"Attack": 1,
		"Defense": 1,
		"Energy": 1,
		"Speed": 1,
		"Technology": 1,
		"Luck": 1,
		}

var rng = RandomNumberGenerator.new()
var attack_result = 0
var advantage = "None"
var attack_count_total = 0
var attack_num = 0
var total_stats_count = 0
var total_attacks = 0

var confirmed_territory = []
var searching_territory = []
var remaining_territory = []
var temp_territory_array = []

var remaining_attacks_search = []
var remaining_attacks = []

var confirmed_territory_attack = []
var searching_territory_attack = []
var remaining_territory_attack = []
var temp_territory_array_attack = []
var this_tile_was_attacked = false

var next_attack

var tile = ["00", "None", "Empty", 1, [1, 1, 1], [], Vector2(0, 0), 0]
var tile_lives = 1
var tile_attacks = 0

var neighbors = []

var player_order = []
var player_order_original = []
var player_order_temp = []
var player_order_speed = {}
var swapped = false
var prev = "Prev"

var conquest_order = []

@onready var tile_manager: Node2D = $"../../TileManager"
@onready var player_manager: Node2D = $"../../PlayerManager"
@onready var main_camera: Camera2D = $"../../MainCamera"
@onready var conquest_timer: Timer = $ConquestTimer
@onready var battle_ui: Node2D = $"../../UiManager/BattleUI"
@onready var attack_manager: Node2D = $"../../AttackManager"
@onready var start_conquest_button: Node2D = $"../../UiManager/ButtonUI/StartConquestButton"

func _ready() -> void:
	tile_manager.return_tile_info.connect(_return_tile_info)
	#tile_manager.return_tile_attacks.connect(_return_tile_attacks)
	tile_manager.change_target_status.connect(_change_target_status)
	player_manager.set_current_player.connect(_set_attacking_player)
	player_manager.return_player_info_conquest.connect(_return_player_info)
	player_manager.update_player_order.connect(_update_player_order)
	player_manager.set_player_order.connect(_set_player_order)
	attack_manager.set_attack_list.connect(_set_attack_list)
	start_conquest_button.start_conquest.connect(_start_conquest)
	
#func _input(event) -> void:
#	if event.is_action_pressed("one"):
#		_get_attack_list()
#		_initiate_attack()

func _start_conquest() -> void:
	emit_signal("set_tile_attack_value", {})
	_get_attack_list()
	#replace this for loop with the names in the player order
	conquest_order = player_order.duplicate(true)
	#for key in attack_list:
	for key in conquest_order:
		if attack_list[key].is_empty():
			pass
		else:
			emit_signal("get_player_info", key)
			if player["Status"] == "Dead":
				pass
			else:
				_set_attacking_player(player)
				#need to add an await to wait for the entire attack to go through
				await _perform_attacks(attacking_player_conquest["Territory"], attack_list, attacking_player_conquest["Base"])
	_end_attack_sequence()

func _get_attack_list() -> void:
	emit_signal("get_attack_list")
	
func _set_attack_list(attack_list_send) -> void:
	attack_list = attack_list_send

func _change_target_status(id, previous_attack_count, current_attack_count) -> void:
	already_target = false
	for n in targets:
		if n == id:
			already_target = true
			current_target = n
	if current_attack_count > 0:
		if not already_target:
			targets.push_back(id)
	else:
		if already_target:
			targets.erase(current_target)
	attack_count_total -= previous_attack_count
	attack_count_total += current_attack_count
	
func _return_tile_info(tile_info) -> void:
	tile = tile_info
	
func _return_player_info(player_info) -> void:
	player = player_info.duplicate(true)
	
func _tile_neighbors() -> Array:
	return tile["Neighbors"].duplicate(true)
	
func _set_attacking_player(player_info) -> void:
	attacking_player_name = player_info["Name"]
	attacking_player_base = player_info["Base"]
	attacking_player_territory = player_info["Territory"]
	attacking_player_color = player_info["Color"]
	attacking_player_stats = player_info["Stats"]
	for key in player_info["Stat Boosts"]:
		attacking_player_stats[key] += player_info["Stat Boosts"][key]
	
	attacking_player_conquest = player_info.duplicate(true)
	
func _set_defending_player(player_info) -> void:
	defending_player_name = player_info["Name"]
	defending_player_base = player_info["Base"]
	defending_player_territory = player_info["Territory"]
	defending_player_color = player_info["Color"]
	defending_player_stats = player_info["Stats"]
	for key in player_info["Stat Boosts"]:
		defending_player_stats[key] += player_info["Stat Boosts"][key]
	
	defending_player_conquest = player_info.duplicate(true)
	
#func _initiate_attack() -> void:
#	_perform_attacks(attacking_player_territory, targets, attacking_player_base)
	
func _perform_attacks(c_territory, attacks, base) -> bool:
	print(c_territory)
	if attacks[attacking_player_conquest["Name"]].is_empty():
		return true
	
	emit_signal("start_attack_sequence", attacking_player_name, attacking_player_color)
	for key in attacks[attacking_player_conquest["Name"]]:
		emit_signal("get_tile_info", key)
		_move_camera(tile["Position"])
		break
	main_camera.target_zoom = 3.0
	
	remaining_attacks = attacks[attacking_player_conquest["Name"]].duplicate(true)
	
	remaining_territory_attack = c_territory.duplicate(true)
	confirmed_territory_attack = []
	searching_territory_attack = [base]
	remaining_territory_attack.erase(base)
	for key in attacks[attacking_player_conquest["Name"]]:
		
		remaining_territory_attack.append(key)
	this_tile_was_attacked = false
	for i in range(remaining_territory_attack.size() + 1):
		if remaining_territory_attack == []:
			print("No more attacks to go through. Success!")
			#_end_attack_sequence()
			await get_tree().create_timer(0.5).timeout
			break
		
		if searching_territory_attack == []:
			print("The remaining attacks are no longer accessable. Failed...")
			#_end_attack_sequence()
			await get_tree().create_timer(0.5).timeout
			
			for a in remaining_territory_attack:
				_failed_attack(a)
			break
			
		confirmed_territory_attack.append_array(searching_territory_attack)
		
		for s in searching_territory_attack:
			emit_signal("get_tile_info", s)
			neighbors = _tile_neighbors()
			for n in neighbors:
				for r in remaining_territory_attack:
					if n == r:
						this_tile_was_attacked = false
						
						for a in remaining_attacks:
							if n == a:
								remaining_territory_attack.erase(a)
								attacks.erase(a)
								await get_tree().create_timer(0.25).timeout
								await _attack_tile(a)
								this_tile_was_attacked = true
								break
						if this_tile_was_attacked:
							break
						temp_territory_array_attack.push_back(n)
						break
						
				remaining_territory_attack.erase(n)
				
		searching_territory_attack = temp_territory_array_attack.duplicate(true)
		temp_territory_array_attack.clear()
	return true
	
	#for a in attacks:
		#emit_signal("get_tile_info", a)
		#_move_camera(tile[6])
		#await get_tree().create_timer(0.25).timeout
		#if _successful_attack("idk"):
			#emit_signal("attack_tile", a, attacking_player_conquest)
	
func _get_tile_attacks(tile_name) -> void:
	#emit_signal("get_tile_attacks", tile["ID"])
	tile_attacks = attack_list[attacking_player_name][tile_name]
	
#func _return_tile_attacks(attack_amount) -> void:
	#tile_attacks = attack_amount

func _attack_tile(attacked_tile) -> bool:
	emit_signal("get_tile_info", attacked_tile)
	_move_camera(tile["Position"])
	if tile["Attacked"] == true:
		print("This tile was already attacked this conquest.")
		_failed_attack(attacked_tile)
		return true
	
	if tile["Owner"] == "None":
		_successful_attack(attacked_tile, "None")
		emit_signal("attacking_neutral_tile")
		return true
	emit_signal("get_player_info", tile["Owner"])
	_set_defending_player(player)
	
	tile_lives = tile["Lives"]
	_get_tile_attacks(tile["ID"])
	#tile_attacks = tile[7]
	
	if (attacking_player_stats["Attack"] > defending_player_stats["Defense"]):
		advantage = "Attacker"
		total_stats_count = (2 + attacking_player_stats["Attack"] - defending_player_stats["Defense"])
	else:
		#also give defender advantage in ties, although that doesnt really do anything
		advantage = "Defender"
		total_stats_count = (2 + defending_player_stats["Defense"] - attacking_player_stats["Attack"])
		
	attack_num = 0
	emit_signal("create_attack_animation", attacking_player_name, attacking_player_color, defending_player_name, defending_player_color,
	 attacking_player_stats["Attack"], defending_player_stats["Defense"], total_stats_count, advantage)
	for n in range(tile_attacks):
		
		attack_num += 1
		
		attack_result = rng.randi_range(1, total_stats_count)
		
		if advantage == "Attacker":
			if attack_result != (total_stats_count):
				tile_lives -= 1
				emit_signal("animate_attack", "Attacker", attack_num, attack_result, total_stats_count)
				await battle_ui.finished_attack_animation
				if tile_lives <= 0:
					await get_tree().create_timer(0.5).timeout
					_successful_attack(attacked_tile, attacking_player_name)
					return true
				else:
					emit_signal("update_tile_lives", attacked_tile, tile_lives)
				await get_tree().create_timer(0.5).timeout
			else:
				emit_signal("animate_attack", "Defender", attack_num, attack_result, total_stats_count)
				await battle_ui.finished_attack_animation
				await get_tree().create_timer(0.5).timeout
				print ("Attack Missed: " + attacked_tile)
					
		elif advantage == "Defender":
			if attack_result == 1:
				tile_lives -= 1
				emit_signal("animate_attack", "Attacker", attack_num, attack_result, total_stats_count)
				await battle_ui.finished_attack_animation
				if tile_lives <= 0:
					await get_tree().create_timer(0.5).timeout
					_successful_attack(attacked_tile, attacking_player_name)
					return true
				else: 
					emit_signal("update_tile_lives", attacked_tile, tile_lives)
				await get_tree().create_timer(0.5).timeout
			else:
				emit_signal("animate_attack", "Defender", attack_num, attack_result, total_stats_count)
				await battle_ui.finished_attack_animation
				await get_tree().create_timer(0.5).timeout
				print ("Attack Missed: " + attacked_tile)
					
	
	_failed_attack(attacked_tile)
	return true
	
#this also triggers on fully successful attack, not succesful coin flip
func _successful_attack(attacked_tile, player_name) -> void:
	
	if player_name != "None":
		defending_player_territory.erase(attacked_tile)
		_update_territory(defending_player_name, defending_player_territory)
	emit_signal("attack_tile", attacked_tile, attacking_player_conquest)
	emit_signal("end_attack_animation", "Success")
	attacking_player_territory.append(attacked_tile)
	_update_territory(attacking_player_name, attacking_player_territory)
	temp_territory_array_attack.push_back(attacked_tile)
	
	print("Attack Succeeded: " + attacked_tile)

#fix this: want to trigger things on failed coin flip instead of fully failed attack
func _failed_attack(attacked_tile) -> void:
	emit_signal("set_lives", attacked_tile, tile_lives)
	emit_signal("attack_tile_failed", attacked_tile)
	emit_signal("end_attack_animation", "Failed")
	
	print ("Attack Failed: " + attacked_tile)

func _move_camera(pos) -> void:
	main_camera.position = pos

func _update_territory(player_name, terr) -> void:
	emit_signal("update_territory", player_name, terr)
	
func _end_attack_sequence() -> void:
	emit_signal("set_tile_already_attacked", "Reset")
	await get_tree().create_timer(0.5).timeout
	emit_signal("end_attack_sequence")
	main_camera.target_zoom = 1.0
	_move_camera(Vector2(0, 0))

func _set_player_order(order_list, order_speed_list) -> void:
	player_order = order_list.duplicate(true)
	player_order_original = order_list.duplicate(true)
	player_order_speed = order_speed_list.duplicate(true)
	
func _update_player_order(player_name, player_speed) -> void:
	player_order_speed[player_name] = player_speed
	player_order_temp = player_order_original.duplicate(true)
	for n in range(player_order_temp.size()):
		swapped = false
		for x in range(player_order_temp.size() - n - 1):
			
			if player_order_speed[player_order_temp[x]] < player_order_speed[player_order_temp[x + 1]]:
				prev = player_order_temp[x]
				player_order_temp[x] = player_order_temp[x + 1]
				player_order_temp[x + 1] = prev
				swapped = true
				
		if !swapped:
			break
				
	player_order = player_order_temp.duplicate(true)
	emit_signal("set_player_order", player_order, player_order_speed)
	print(player_order_speed)
