extends Node2D

signal set_inventory_category

@onready var inventory: Node2D = $".."
@onready var inventory_tab_background: ColorRect = $InventoryTabBackground

@onready var inventory_tab_label: Label = $InventoryTabLabel
var category_name = "Category"

func _ready() -> void:
	inventory.set_inventory_category.connect(_set_inventory_category)
	
	
	inventory_tab_label.text = category_name

func _on_inventory_tab_control_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				emit_signal("set_inventory_category", category_name)

func _set_inventory_category(current_category) -> void:
	if current_category == category_name:
		inventory_tab_background.color = Color(1, 1, 0, 0.4)
	else:
		inventory_tab_background.color = Color(0, 0, 0, 1)
		
