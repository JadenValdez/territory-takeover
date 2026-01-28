extends Node2D

#signal set_item_page
signal set_current_category
#signal set_current_item_window
#signal show_category_tooltip
#signal hide_category_tooltip

var category_name = "Category"

@onready var shop_ui: Node2D = $".."
@onready var shop_item_tab_label: Label = $ShopItemTabLabel
@onready var shop_item_tab_control: Control = $ShopItemTabControl
@onready var shop_item_tab_shape: Polygon2D = $ShopItemTabShape

func _ready() -> void:
	shop_ui.set_current_category.connect(_set_current_category)
	shop_item_tab_label.text = category_name
	#shop_ui.update_item_tab_stock.connect(_update_item_tab_stock)
	
func _on_shop_item_tab_control_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				#emit_signal("set_item_page", category_name)
				emit_signal("set_current_category", category_name)
				#emit_signal("set_current_item_window", "Current")
				#emit_signal("show_category_tooltip", category_name)

#func _on_shop_item_tab_control_mouse_entered() -> void:
	#emit_signal("show_category_tooltip", category_name)

#func _on_shop_item_tab_control_mouse_exited() -> void:
	#emit_signal("hide_category_tooltip")

func _set_current_category(current_category) -> void:
	if category_name == current_category:
		shop_item_tab_shape.color = Color(1, 1, 0, 0.4)
	else:
		shop_item_tab_shape.color = Color(0, 0, 0, 1)
		
#func _update_item_tab_stock(current_item_category, current_item_name, _current_item_stock) -> void:
#	if current_item_category == category_name:
#		for i in items_list:
#			if i["Name"] == current_item_name:
#				if str(i["Stock"]) == "Infinity":
#					pass
#				else:
#					i["Stock"] -= 1
#				return
#		print("Item not found")
