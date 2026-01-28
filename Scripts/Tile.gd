extends Node2D

@onready var tile_sprite: AnimatedSprite2D = $TileSprite
@onready var conquest_phase: Node2D = $"../../PhaseManager/ConquestPhase"
@onready var tile_manager: Node2D = $".."
const BUILDING_TILE_SPRITE = preload("res://Scenes/BuildingTileSprite.tscn")

signal choose_tile
signal change_target_status
signal return_tile_info
signal return_tile_attacks

signal show_tile_info
signal hide_tile_info

signal tile_left_click
signal tile_right_click

signal add_item_sprite
signal remove_item_sprite
signal set_building_positions

signal unselect_tile

signal reduce_item_inventory
signal add_item_inventory

signal update_tile_tooltip

signal update_base_lives
signal player_defeated

var tile = {
	"ID": "00",
	"Owner": "None",
	"Status": "Empty",
	"Lives": 1,
	"Color": [1, 1, 1],
	"Neighbors": [],
	"Position": Vector2(0, 0),
	"Attacked": false
	}
var id = "00"
var tile_owner = "None"
var status = "Empty"
var lives = 1
var current_color = [1, 1, 1]
var neighbors = []
var pos = Vector2(0, 0)

var previous_attack_count = 0
var current_attack_count = 0

var defeated_name = "None"
var already_attacked = false

var current_building_num = 0
var temp_building_num = 0
var building_positions = [
	[],
	[Vector2(0,0)], 
	[Vector2(-10, 0), Vector2(10, 0)], 
	[Vector2(-10, 10), Vector2(10, 10), Vector2(0, -10)], 
	[Vector2(-10, 10), Vector2(10, 10), Vector2(-10, -10), Vector2(10, -10)]
]

func _ready() -> void:
	conquest_phase.attack_tile.connect(_on_player_attack_tile)
	conquest_phase.attack_tile_failed.connect(_reset_attack_count)
	tile_manager.get_tile_info.connect(_return_tile_info)
	tile_manager.get_tile_attacks.connect(_get_tile_attacks)
	tile_manager.set_lives.connect(_set_lives)
	tile_manager.add_attack_count.connect(_add_attack_count)
	tile_manager.subtract_attack_count.connect(_subtract_attack_count)
	tile_manager.set_tile_already_attacked.connect(_set_tile_already_attacked)
	tile_manager.set_tile_attack_value.connect(_set_tile_attack_value)
	tile_manager.select_tile.connect(_select_tile)
	tile_manager.unselect_tile.connect(_unselect_tile)
	tile_manager.place_item.connect(_place_item)
	tile_manager.remove_item.connect(_remove_item)
	tile_manager.confirm_building_placements.connect(_confirm_building_placements)
	tile_manager.update_tile_lives.connect(_update_tile_lives)
	tile_manager.player_defeated.connect(_player_defeated)
	
	for n in range(4):
		var instance_BUILDING_TILE_SPRITE = BUILDING_TILE_SPRITE.instantiate()
		instance_BUILDING_TILE_SPRITE.sprite_num = n + 1
		instance_BUILDING_TILE_SPRITE.position = building_positions[n+1][n]
		add_child(instance_BUILDING_TILE_SPRITE)
	
	if status == "Base":
		print("Base: " + id)
		tile_sprite.play("Base Flip 1")
		

	tile = {
	"ID": id,
	"Owner": tile_owner,
	"Status": status,
	"Lives": lives,
	"Color": current_color,
	"Neighbors": neighbors,
	"Position": pos,
	"Attacked": already_attacked
	}
				
func _on_control_mouse_entered() -> void:
	emit_signal("show_tile_info", tile)

func _on_control_mouse_exited() -> void:
	emit_signal("hide_tile_info", tile)

func _on_control_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		#if current_phase == "Conquest":
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				emit_signal("tile_left_click", id)
				#current_attack_count += 1
				#emit_signal("choose_tile", id)
				#_change_label()
			MOUSE_BUTTON_RIGHT:
				emit_signal("tile_right_click", id, status)
				#current_attack_count -= 1
				#if current_attack_count < 0:
				#	current_attack_count = 0
				#_change_label()
					
func _update_profile() -> void:
	tile = {
	"ID": id,
	"Owner": tile_owner,
	"Status": status,
	"Lives": lives,
	"Color": current_color,
	"Neighbors": neighbors,
	"Position": pos,
	"Attacked": already_attacked
	}
	emit_signal("update_tile_tooltip", tile)
	
func _on_player_attack_tile(target_id, player) -> void:
	if (id == target_id):
		if status == "Base":
			emit_signal("player_defeated", tile_owner, player)
		tile_owner = player["Name"]
		current_color = player["Color"]
		current_attack_count = 0
		lives = 1
		status = "Empty"
		tile_sprite.play("Color Flip 1")
		already_attacked = true
		_change_label()
		
func _set_lives(attacked_tile, tile_lives) -> void:
	if (id == attacked_tile):
		lives = tile_lives
		_update_profile()
		
func _add_attack_count(tile_name) -> void:
	if id == tile_name:
		current_attack_count += 1
		_change_label()
		
func _subtract_attack_count(tile_name) -> void:
	if id == tile_name:
		current_attack_count -= 1
		if current_attack_count < 0:
			current_attack_count = 0
		_change_label()
		
func _reset_attack_count(tile_name) -> void:
	if (id == tile_name):
		current_attack_count = 0
		_change_label()
		
func _change_label() -> void:
	if current_attack_count > 0:
		$Label.text = str(current_attack_count)
	else:
		$Label.text = ""
	#emit_signal("change_target_status", id, previous_attack_count, current_attack_count)
	previous_attack_count = current_attack_count
	_update_profile()

func _tiles_in_range() -> Array:
	return neighbors
	
func _return_tile_info(tile_name) -> void:
	if tile_name == id:
		emit_signal("return_tile_info", tile)
		
func _get_tile_attacks(tile_name) -> void:
	if tile_name == id:
		emit_signal("return_tile_attacks", current_attack_count)

func _on_tile_sprite_animation_finished() -> void:
	if tile_sprite.animation == "Color Flip 1":
		tile_sprite.modulate = Color(current_color[0], current_color[1], current_color[2])
		tile_sprite.play("Color Flip 2")
		_update_profile()
	if tile_sprite.animation == "Base Flip 1":
		tile_sprite.modulate = Color(current_color[0], current_color[1], current_color[2])
		tile_sprite.play("Base Flip 2")

func _set_tile_already_attacked(tile_name) -> void:
	if tile_name == tile["ID"]:
		already_attacked = true
		_update_profile()
	elif tile_name == "Reset":
		already_attacked = false
		_update_profile()
	
func _set_tile_attack_value(attack_list) -> void:
	for key in attack_list:
		if key == tile["ID"]:
			current_attack_count = attack_list[key]
			_change_label()
			return
	current_attack_count = 0
	_change_label()

func _select_tile(tile_name) -> void:
	if tile_name == tile["ID"]:
		if status != "Base":
			tile_sprite.modulate = Color(1, 1, 0)
		
func _unselect_tile(tile_name) -> void:
	if tile_name == tile["ID"]:
		tile_sprite.modulate = Color(current_color[0], current_color[1], current_color[2])
	elif tile_name == "All Tiles":
		tile_sprite.modulate = Color(current_color[0], current_color[1], current_color[2])
		
func _place_item(tile_name, item_name, item_sprite, item_functionality, item_placement, current_player_name):
	if tile_name == tile["ID"]:
		if status == "Base":
			print("You cannot use items on bases.")
			return
		if item_placement == "Own Tiles":
			if tile["Owner"] == current_player_name:
				if status == "Empty":
					status = item_name
				if status != item_name:
					print("You cant combine items ig")
				else:
					if temp_building_num == 4:
						print("You have placed the maximum amount of buildings. (4)")
						return
					temp_building_num += 1
					emit_signal("add_item_sprite", temp_building_num, item_sprite)
					emit_signal("set_building_positions", building_positions[temp_building_num])
					for key in item_functionality:
						if key == "Lives":
							lives += item_functionality[key]
					emit_signal("reduce_item_inventory")
					_update_profile()
			else:
				print ("You can only place this item on your own tiles")
		else:
			pass

func _remove_item(tile_name, item_name, item_functionality):
	if tile_name == tile["ID"]:
		if temp_building_num <= current_building_num:
			print("You can't remove already placed buildings.")
			return
		temp_building_num -= 1
		if temp_building_num == 0:
			status = "Empty"
		emit_signal("remove_item_sprite", temp_building_num)
		emit_signal("set_building_positions", building_positions[temp_building_num])
		for key in item_functionality:
			if key == "Lives":
				lives -= item_functionality[key]
		emit_signal("add_item_inventory", item_name)
		_update_profile()
		if temp_building_num == current_building_num:
			emit_signal("unselect_tile", tile["ID"])
		
		
func _confirm_building_placements() -> void:
	current_building_num = temp_building_num
	emit_signal("unselect_tile", tile["ID"])
	
func _update_tile_lives(tile_name, tile_lives):
	if tile_name == tile["ID"]:
		lives = tile_lives
		if status == "Base":
			emit_signal("update_base_lives", tile_owner, lives)
		#im assuming only 1 life is lost here
		elif status == "Fort":
			temp_building_num = lives - 1
			for n in range(current_building_num - temp_building_num):
				#waiting for attack animation to finish
				emit_signal("remove_item_sprite", current_building_num - 1 - n)
			current_building_num = temp_building_num
			emit_signal("set_building_positions", building_positions[current_building_num])
			if current_building_num <= 0:
				status = "Empty"
		_update_profile()
		
func _player_defeated(player_name, winner):
	if tile_owner == player_name:
		tile_owner = winner["Name"]
		current_color = winner["Color"]
		tile_sprite.play("Color Flip 1")
		_change_label()
