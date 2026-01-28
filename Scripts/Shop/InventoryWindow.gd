extends Node2D

signal get_item_sprite
signal set_active_item

@onready var inventory: Node2D = $".."
@onready var inventory_window_label_name: Label = $InventoryWindowLabelName
@onready var inventory_window_label_amount: Label = $InventoryWindowLabelAmount
@onready var inventory_window_sprite: Sprite2D = $InventoryWindowSprite
@onready var inventory_window_tile_sprite: Sprite2D = $InventoryWindowTileSprite
@onready var inventory_window_foreground: ColorRect = $InventoryWindowForeground

var current_item = "Item"
var current_category = "Buildings"
var window_number = 0
var index = 0

var sprite_load
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	inventory.update_inventory_windows.connect(_update_inventory_windows)
	inventory.return_item_sprite.connect(_return_item_sprite)
	inventory.set_active_item.connect(_set_active_item)


func _on_inventory_window_window_control_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				emit_signal("set_active_item", current_item, current_category)

func _update_inventory_windows(items, category_name) -> void:
	current_category = category_name
	index = 0
	for key in items:
		if index == window_number:
			inventory_window_label_name.text = key
			inventory_window_label_amount.text = str(items[key])
			current_item = key
			emit_signal("get_item_sprite", key)
		index += 1
	if index <= 2:
		for i in range(3 - index):
			if index == window_number:
				inventory_window_label_name.text = ""
				inventory_window_label_amount.text = ""
				inventory_window_sprite.visible = false
				inventory_window_tile_sprite.visible = false
			index += 1

func _return_item_sprite(key, sprite, category_name) -> void:
	if current_item == key:
		sprite_load = load(sprite[0])
		inventory_window_sprite.texture = sprite_load
		inventory_window_sprite.scale = Vector2(sprite[1] / 2.0, sprite[1] / 2.0)
		inventory_window_sprite.visible = true
		if category_name == "Buildings":
			inventory_window_tile_sprite.visible = true
		else:
			inventory_window_tile_sprite.visible = false
			
func _set_active_item(item_name) -> void:
	if item_name == "None":
		inventory_window_foreground.color = Color(0, 0, 0, 1)
	elif item_name == current_item:
		inventory_window_foreground.color = Color(1, 1, 0, 0.4)
	else:
		inventory_window_foreground.color = Color(0, 0, 0, 1)
