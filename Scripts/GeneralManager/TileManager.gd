extends Node2D

signal initialize_ui

signal choose_tile

signal change_target_status
signal set_lives

signal get_tile_info
signal return_tile_info

signal show_tile_info
signal hide_tile_info

signal get_tile_attacks
signal return_tile_attacks

signal add_attack_count
signal subtract_attack_count

signal set_tile_attack_value
signal set_tile_already_attacked

signal select_tile
signal unselect_tile

signal get_building_info
signal get_building_info_tile
signal place_item
signal remove_item
signal confirm_building_placements

signal update_tile_tooltip

signal reduce_item_inventory
signal add_item_inventory

signal finished_attack_animation
signal update_tile_lives

signal update_base_lives
signal player_defeated

@onready var player_manager: Node2D = $"../PlayerManager"
@onready var phase_manager: Node2D = $"../PhaseManager"
@onready var attack_manager: Node2D = $"../AttackManager"
@onready var item_manager: Node2D = $"../ItemManager"
@onready var conquest_phase: Node2D = $"../PhaseManager/ConquestPhase"
@onready var inventory: Node2D = $"../UiManager/Inventory"
@onready var battle_ui: Node2D = $"../UiManager/BattleUI"

@onready var tile = preload("res://Scenes/Tile.tscn")

var rowNames = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
var rows = 10
var columns = 10

var targets = []
var already_target = false
var current_target = "00"

var player_info = {}

var walls = []
var keyPoints = []

var current_phase = "Conquest"
var current_action = "Selecting Tiles"

var selected_tiles = {}

var current_player = {}
var current_player_name = "None"

func _ready() -> void:
	phase_manager.set_current_phase.connect(_set_current_phase)
	phase_manager.set_current_action.connect(_set_current_action)
	conquest_phase.get_tile_info.connect(_get_tile_info)
	attack_manager.get_tile_info.connect(_get_tile_info)
	conquest_phase.get_tile_attacks.connect(_get_tile_attacks)
	conquest_phase.set_lives.connect(_set_lives)
	attack_manager.set_tile_attack_value.connect(_set_tile_attack_value)
	conquest_phase.set_tile_attack_value.connect(_set_tile_attack_value)
	conquest_phase.set_tile_already_attacked.connect(_set_tile_already_attacked)
	player_manager.set_bases.connect(_set_bases)
	player_manager.setup_tile_selections.connect(_setup_tile_selections)
	player_manager.set_current_player.connect(_set_current_player)
	item_manager.return_building_info.connect(_return_building_info)
	inventory.confirm_building_placements.connect(_confirm_building_placements)
	conquest_phase.update_tile_lives.connect(_update_tile_lives)
	battle_ui.finished_attack_animation.connect(_finished_attack_animation)

func _set_current_player(c_player)  -> void:
	current_player = c_player.duplicate(true)
	current_player_name = current_player["Name"]
	emit_signal("unselect_tile", "All Tiles")
	for key in selected_tiles[current_player_name]:
		emit_signal("select_tile", key)

func _set_bases(info) -> void:
	player_info = info.duplicate(true)

func _input(event):
	if event.is_action_pressed("space"):
		board_builder()
		
func board_builder():
	var tile_name = "00"
	var tile_owner = "None"
	var status = "Empty"
	var lives = 1
	var current_color = [1, 1, 1]
	var neighbors = []
	var pos
	
	var default = true
	
	var offsetX = (rows - 1) * 25
	var offsetY = (columns - 1) * 25
	var xLink = 0
	var yLink = 0
	
	for x in range(rows):
		for y in range(columns):
			var instance = tile.instantiate()
			
			default = true
			neighbors.clear()
			
			tile_name = rowNames[x] + str(y + 1)
			
			pos = Vector2(x * 50 - offsetX, y * 50 - offsetY)
			instance.position = pos
			
			for key in player_info:
				if player_info[key]["Base"] == tile_name:
					tile_owner = key
					status = "Base"
					lives = 3
					current_color = player_info[key]["Color"]
					
					default = false
					
			for num in 4:
				if num == 0:
					xLink = x - 1
					yLink = y
				if num == 1:
					xLink = x
					yLink = y - 1
				if num == 2:
					xLink = x + 1
					yLink = y
				if num == 3:
					xLink = x
					yLink = y + 1
					
				if xLink >= 0 && xLink < rows && yLink >= 0 && yLink < columns:
					neighbors.push_back(rowNames[xLink] + str(yLink + 1))
					
			instance.id = tile_name
			instance.neighbors = neighbors.duplicate(true)
			instance.pos = pos
						
			if default == true:
				tile_owner = "None"
				status = "Empty"
				lives = 1
				current_color = [1, 1, 1]
				
			instance.tile_owner = tile_owner
			instance.status = status
			instance.lives = lives
			instance.current_color = current_color
			instance.current_attack_count = 0
			
			#instance.current_phase = current_phase
			
			add_child(instance)
			
			instance.choose_tile.connect(_choose_tile)
			instance.change_target_status.connect(_change_target_status)
			instance.return_tile_info.connect(_return_tile_info)
			instance.return_tile_attacks.connect(_return_tile_attacks)
			
			instance.show_tile_info.connect(_show_tile_info)
			instance.hide_tile_info.connect(_hide_tile_info)
			
			instance.tile_left_click.connect(_tile_left_click)
			instance.tile_right_click.connect(_tile_right_click)
			
			instance.unselect_tile.connect(_unselect_tile)
			
			instance.update_tile_tooltip.connect(_update_tile_tooltip)
			
			instance.reduce_item_inventory.connect(_reduce_item_inventory)
			instance.add_item_inventory.connect(_add_item_inventory)
			
			instance.update_base_lives.connect(_update_base_lives)
			instance.player_defeated.connect(_player_defeated)
			
			await get_tree().create_timer(0.01).timeout
	emit_signal("initialize_ui")

func _choose_tile(id):
	emit_signal("choose_tile", id)
	
func _set_current_phase(phase) -> void:
	current_phase = phase
	
func _set_current_action(action) -> void:
	current_action = action
	
func _change_target_status(id, previous_attack_count, current_attack_count):
	emit_signal("change_target_status", id, previous_attack_count, current_attack_count)
			
func _get_tile_info(tile_name) -> void:
	emit_signal("get_tile_info", tile_name)
	
func _return_tile_info(tile_info) -> void:
	emit_signal("return_tile_info", tile_info)
	
func _show_tile_info(tile_info) -> void:
	emit_signal("show_tile_info", tile_info)
	
func _hide_tile_info(tile_info) -> void:
	emit_signal("hide_tile_info", tile_info)
	
func _get_tile_attacks(tile_id) -> void:
	emit_signal("get_tile_attacks", tile_id)

func _return_tile_attacks(attack_amount) -> void:
	emit_signal("return_tile_attacks", attack_amount)
	
func _set_lives(attacked_tile, tile_lives) -> void:
	emit_signal("set_lives", attacked_tile, tile_lives)
	
func _tile_left_click(tile_name) -> void:
	if current_action == "Selecting Tiles":
		emit_signal("add_attack_count", tile_name)
	elif current_action == "Placing Buildings":
		emit_signal("get_building_info", "Place", tile_name)
		if selected_tiles[current_player_name].has(tile_name):
			pass
		else:
			#selected_tiles[current_player_name].append(tile_name)
			#emit_signal("select_tile", tile_name)
			pass
	
func _tile_right_click(tile_name, status) -> void:
	if current_action == "Selecting Tiles":
		emit_signal("subtract_attack_count", tile_name)
	elif current_action == "Placing Buildings":
		if status == "Empty" || status == "Base":
			pass
		else:
			emit_signal("get_building_info_tile", "Remove", tile_name, status)
			#change this so it only happens if a tile has no more temp buildings on it
			#wait i already have it lmao
			#if selected_tiles[current_player_name].has(tile_name):
				#selected_tiles[current_player_name].erase(tile_name)
				#emit_signal("unselect_tile", tile_name)
		
func _unselect_tile(tile_name) -> void:
	if selected_tiles[current_player_name].has(tile_name):
		selected_tiles[current_player_name].erase(tile_name)
		emit_signal("unselect_tile", tile_name)
		
func _set_tile_attack_value(attack_list) -> void:
	emit_signal("set_tile_attack_value", attack_list)
		
func _set_tile_already_attacked(tile_name) -> void:
	emit_signal("set_tile_already_attacked", tile_name)
	
func _setup_tile_selections(player_list) -> void:
	for key in player_list:
		selected_tiles[key] = []
		
func _return_building_info(action, tile_name, item_name, item_sprite, item_functionality, item_placement):
	if action == "Place":
		emit_signal("place_item", tile_name, item_name, item_sprite, item_functionality, item_placement, current_player_name)
		if selected_tiles[current_player_name].has(tile_name):
			pass
		else:
			selected_tiles[current_player_name].append(tile_name)
			emit_signal("select_tile", tile_name)
			#this is dumb
	elif action == "Remove":
		emit_signal("remove_item", tile_name, item_name, item_functionality)
		
func _confirm_building_placements() -> void:
	emit_signal("confirm_building_placements")

func _update_tile_tooltip(tile_info) -> void:
	emit_signal("update_tile_tooltip", tile_info)
	
func _reduce_item_inventory() -> void:
	emit_signal("reduce_item_inventory")
	
func _add_item_inventory(item_name) -> void:
	emit_signal("add_item_inventory", item_name)

func _update_tile_lives(tile_name, tile_lives) -> void:
	emit_signal("update_tile_lives", tile_name, tile_lives)

func _finished_attack_animation() -> void:
	emit_signal("finished_attack_animation")

func _update_base_lives(player_name, base_lives) -> void:
	emit_signal("update_base_lives", player_name, base_lives)

func _player_defeated(player_name, winner) -> void:
	emit_signal("player_defeated", player_name, winner)
