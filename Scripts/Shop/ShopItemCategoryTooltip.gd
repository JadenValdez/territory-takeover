extends Node2D

@onready var shop_ui: Node2D = $".."
@onready var description_label: Label = $DescriptionLabel

var category_descriptions = {
	"Buildings": "Placed on tiles for passive effects",
	"Boosts": "Gain stat boosts during the Conquest phase",
	"Conquest": "Used during attacks with powerful effects",
	"Misc.": "Other items with miscellaneous uses"
}

func _ready() -> void:
	shop_ui.show_category_tooltip.connect(_show_category_tooltip)
	shop_ui.hide_category_tooltip.connect(_hide_category_tooltip)

func _show_category_tooltip(current_category) -> void:
	visible = true
	description_label.text = category_descriptions.get(current_category)
	
func _hide_category_tooltip() -> void:
	visible = false
