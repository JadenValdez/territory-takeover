extends Node2D

signal open_shop
signal close_shop

@onready var shop_button_label: Label = $ShopButtonLabel
@onready var shop_ui: Node2D = $"../../ShopUI"

var shop_open = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	shop_ui.open_shop.connect(_open_shop)
	shop_ui.close_shop.connect(_close_shop)


func _on_shop_button_control_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				if shop_open:
					emit_signal("close_shop")
				else:
					emit_signal("open_shop")

func _open_shop() -> void:
	shop_open = true
	shop_button_label.text = "Close"
	
func _close_shop() -> void:
	shop_open = false
	shop_button_label.text = "Shop"
