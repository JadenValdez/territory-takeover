extends Node2D

@onready var shop_ui: Node2D = $".."
@onready var cost_label: Label = $CostLabel
@onready var symbol: Label = $Symbol

func _ready() -> void:
	shop_ui.show_next_stat_preview.connect(_show_next_stat_preview)
	shop_ui.hide_next_stat_preview.connect(_hide_next_stat_preview)

func _show_next_stat_preview(price, action, node_position) -> void:
	position = node_position
	cost_label.text = str(price)
	if action == "Buy":
		symbol.text = "-"
	elif action == "Sell":
		symbol.text = "+"
	visible = true
	
func _hide_next_stat_preview() -> void:
	visible = false
