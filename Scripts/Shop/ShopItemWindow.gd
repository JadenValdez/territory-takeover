extends Node2D

signal set_item_preview
signal set_current_item_window

@onready var shop_item_window_label: Label = $ShopItemWindowLabel
@onready var shop_item_window_label_cost: Label = $ShopItemWindowLabelCost
@onready var shop_item_window_foreground: ColorRect = $ShopItemWindowForeground
@onready var shop_ui: Node2D = $".."

var index = 0

var window_id = 0
var item_name = "None"
var item_cost = 0
var item_stock = 0
var item_description = ""
var item_sprite = ""
var item_category = "Category"

func _ready() -> void:
	if item_name == "None":
		shop_item_window_label.text = ""
	else:
		shop_item_window_label.text = item_name
	shop_ui.set_item_page.connect(_set_item_page)
	shop_ui.set_current_item_window.connect(_set_current_item_window)

func _on_shop_item_window_control_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				emit_signal("set_item_preview", item_name, item_cost, item_stock, item_description, item_sprite, item_category)
				if item_name != "None":
					emit_signal("set_current_item_window", item_name)
				else:
					emit_signal("set_current_item_window", "")
					
func _set_item_page(category_name, items) -> void:
	index = 0
	for key in items:
		if index == window_id:
			item_name = key
			item_cost = items[key]["Cost"]
			item_stock = items[key]["Stock"]
			item_description = items[key]["Description"]
			item_sprite = items[key]["Sprite"]
			item_category = category_name
			_set_item_window()
		index += 1
	if index <= 2:
		for i in range(3 - index):
			if index == window_id:
				item_name = "None"
				_set_item_window()
			index += 1

func _set_item_window():
	if item_name == "None":
		shop_item_window_label.text = ""
		shop_item_window_label_cost.text = ""
	else:
		shop_item_window_label.text = item_name
		shop_item_window_label_cost.text = "$" + str(item_cost)
		
func _set_current_item_window(current_item) -> void:
	if current_item == "None":
		shop_item_window_foreground.color = Color(0, 0, 0, 1)
	elif current_item == item_name:
		shop_item_window_foreground.color = Color(1, 1, 0, 0.4)
	else:
		shop_item_window_foreground.color = Color(0, 0, 0, 1)
