extends Node2D

@onready var stat_shop_tooltip_label_top: Label = $StatShopTooltipLabelTop
@onready var stat_shop_tooltip_label_description: Label = $StatShopTooltipLabelDescription
@onready var shop_ui: Node2D = $".."

var current_stat = "Stat"

var default = {
	"Attack": "bruh",
	"Defense": "bruh",
	"Energy": "bruh",
	"Speed": "bruh",
	"Technology": "bruh",
	"Luck": "bruh"
	}
	
var descriptions = {
	"Attack": "Makes your attacks stronger during the Conquest phase.
	
	Starting Cost: 5
	Cost Scaling: x2",
	
	"Defense": "Makes your defenses stronger during the Conquest phase.
	
	Starting Cost: 10
	Cost Scaling: x2",
	
	"Energy": "Gives you more tiles to use during the Conquest phase. (might be a temp stat)
	
	Starting Cost: 1
	Cost Scaling: x3",
	
	"Speed": "Determines your spot in the attack order during the Conquest phase. 
	If your Speed stat is the same as other players then whoever was originally higher in the previous Conquest phase gets to act earlier.
	
	Starting Cost: 10
	Cost Scaling: x1.4",
	
	"Technology": "Allows you to gain access stronger items during the Shop phase.
	
	Starting Cost: 50
	Cost Scaling: x5",
	
	"Luck": "Gives you more coins at the beginning of the Shop phase.
	
	Starting Cost: 25
	Cost Scaling: x2"
	}

func _ready() -> void:
	shop_ui.show_stat_tooltip.connect(_show_stat_tooltip)
	shop_ui.hide_stat_tooltip.connect(_hide_stat_tooltip)

func _show_stat_tooltip(stat_name) -> void:
	stat_shop_tooltip_label_top.text = stat_name
	stat_shop_tooltip_label_description.text = descriptions.get(stat_name)
	current_stat = stat_name
	visible = true
	
func _hide_stat_tooltip(stat_name) -> void:
	if stat_name == current_stat:
		visible = false
