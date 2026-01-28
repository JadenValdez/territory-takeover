extends Node2D

signal open_inventory
signal set_inventory_category
signal update_inventory_windows
signal get_item_sprite
signal return_item_sprite
signal set_active_item
signal set_current_action

signal get_building_info

signal confirm_building_placements

signal update_player_inventory

@onready var shop_ui: Node2D = $"../ShopUI"
@onready var item_manager: Node2D = $"../../ItemManager"
@onready var player_manager: Node2D = $"../../PlayerManager"
@onready var phase_manager: Node2D = $"../../PhaseManager"
@onready var tile_manager: Node2D = $"../../TileManager"
@onready var cancel_item: Node2D = $"../ButtonUI/CancelItem"
@onready var use_item: Node2D = $"../ButtonUI/UseItem"
@onready var use_item_label: Label = $"../ButtonUI/UseItem/UseItemLabel"

const INVENTORY_WINDOW = preload("res://Scenes/Shop/InventoryWindow.tscn")
const INVENTORY_TAB = preload("res://Scenes/Shop/InventoryTab.tscn")

var current_player_inventory = {
	"Buildings" : {},
	"Boosts" : {},
	"Conquest" : {},
	"Misc." : {}
	}

var categories = ["Buildings", "Boosts", "Conquest", "Misc."]
var current_category = "Buildings"
var current_items = {}
var inventory_open = false
var final_position = Vector2(0, 616)

var active_item = "None"
var active_category = "None"

var current_phase = "Conquest"
var current_action = "Selecting Tiles"

var current_player_name = "None"

var index = 0

func _ready() -> void:
	shop_ui.update_inventory.connect(_update_inventory)
	item_manager.return_item_sprite.connect(_return_item_sprite)
	phase_manager.set_current_action.connect(_set_current_action)
	cancel_item.cancel_item.connect(_cancel_item)
	use_item.use_item.connect(_use_item)
	tile_manager.get_building_info.connect(_get_building_info)
	tile_manager.reduce_item_inventory.connect(_reduce_item_inventory)
	tile_manager.add_item_inventory.connect(_add_item_inventory)
	player_manager.set_current_player.connect(_set_current_player)
	_set_up_inventory()
	
func _process(_delta):
	position = position.lerp(final_position, 0.15)
	if (position - final_position).length_squared() < 1.0:
		position = final_position

func _set_current_player(player_info) -> void:
	current_player_name = player_info["Name"]

func _on_inventory_button_control_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				if inventory_open:
					final_position = Vector2(0, 616)
					inventory_open = false
				else:
					final_position = Vector2(0, 466)
					inventory_open = true
					
func _set_up_inventory() -> void:
	active_item = "None"
	active_category = "Buildings"
	_make_inventory_tabs()
	_make_inventory_windows()
					
func _make_inventory_tabs() -> void:
	for i in range(categories.size()):
		var instance_INVENTORY_TAB = INVENTORY_TAB.instantiate()
		instance_INVENTORY_TAB.category_name = categories[i]
		instance_INVENTORY_TAB.position = Vector2(0, i * 32 + 45)
		
		instance_INVENTORY_TAB.set_inventory_category.connect(_set_inventory_category)
		
		add_child(instance_INVENTORY_TAB)
	emit_signal("set_inventory_category", "Buildings")
		
func _make_inventory_windows() -> void:
	for i in range(3):
		var instance_INVENTORY_WINDOW = INVENTORY_WINDOW.instantiate()
		instance_INVENTORY_WINDOW.window_number = i
		instance_INVENTORY_WINDOW.current_item = "Item"
		instance_INVENTORY_WINDOW.position = Vector2(i * 193 + 128, 45)
		instance_INVENTORY_WINDOW.scale = Vector2(0.4, 0.4)
		instance_INVENTORY_WINDOW.get_item_sprite.connect(_get_item_sprite)
		instance_INVENTORY_WINDOW.set_active_item.connect(_set_active_item)
		add_child(instance_INVENTORY_WINDOW)

func _set_inventory_category(category_name) -> void:
	current_category = category_name
	emit_signal("set_inventory_category", category_name)
	_set_inventory_windows()
	_set_active_item("None", current_category)

func _update_inventory(inventory) -> void:
	current_player_inventory = inventory.duplicate(true)
	_set_inventory_windows()
	
func _reduce_item_inventory() -> void:
	current_player_inventory[active_category][active_item] -= 1
	if current_player_inventory[active_category][active_item] == 0:
		current_player_inventory[active_category].erase(active_item)
	emit_signal("update_player_inventory", current_player_name, current_player_inventory)
	_set_inventory_windows()
	
func _add_item_inventory(item_name) -> void:
	if current_player_inventory[active_category].has(item_name):
		current_player_inventory[active_category][item_name] += 1
	else: 
		current_player_inventory[active_category][item_name] = 1
	emit_signal("update_player_inventory", current_player_name, current_player_inventory)
	_set_inventory_windows()
	
func _set_inventory_windows() -> void:
	current_items = current_player_inventory[current_category].duplicate(true)
	emit_signal("update_inventory_windows", current_items, current_category)

func _get_item_sprite(key) -> void:
	emit_signal("get_item_sprite", key, current_category)
	
func _return_item_sprite(key, sprite, category_name) -> void:
	emit_signal("return_item_sprite", key, sprite, category_name)

func _set_active_item(item_name, category_name) -> void:
	active_item = item_name
	active_category = category_name
	emit_signal("set_active_item", item_name)
	if category_name == "Buildings":
		emit_signal("set_current_action", "Placing Buildings")
		use_item_label.text = "Confirm"
	else:
		emit_signal("set_current_action", "Selecting Tiles")
		use_item_label.text = "Use Item"
	if item_name != "None":
		cancel_item.visible = true
		use_item.visible = true
	
func _cancel_item() -> void:
	emit_signal("set_current_action", "Selecting Tiles")
	emit_signal("set_active_item", "None")
	cancel_item.visible = false
	use_item.visible = false
	
func _use_item() -> void:
	if active_category == "Buildings":
		emit_signal("confirm_building_placements")
		
func _set_current_action(action):
	current_action = action
	
func _get_building_info(action, tile_name):
	if active_item == "None":
		pass
	else:
		if current_player_inventory[active_category].has(active_item):
			emit_signal("get_building_info", action, tile_name, active_item)
		else:
			print("no item left")
