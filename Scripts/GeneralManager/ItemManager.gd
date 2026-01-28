extends Node2D

signal return_item_sprite

signal return_building_info

@onready var inventory: Node2D = $"../UiManager/Inventory"
@onready var tile_manager: Node2D = $"../TileManager"

var item_list = {
	"Buildings": 
	{"Fort": {"Cost": 50, "Stock": "Infinity", 
	"Sprite": ["res://Assests/Items/fortsprite.png", 5.0],
	"Description": "Will add 1 life to the tile it is placed on.",
	"Functionality": {"Lives": 1},
	"Placement": "Own Tiles"
	}
	}
	, 
	
	"Boosts": 
	{"Shield": {"Cost": 200, "Stock": 10, 
	"Sprite": ["res://Assests/Items/shieldsprite.png", 18.5],
	"Description": "Gives you +1 Defense during this Conquest Phase."},
	"Functionality": {"Defense": 1}
	}
	, 
	
	"Conquest": 
	{"Cannon": {"Cost": 350, "Stock": 5, 
	"Sprite": ["res://Assests/Items/cannonsprite.png", 18.5],
	"Description": "Automatically takes 1 life from a tile during the Conquest Phase. Must be used with an attack."}
	}
	, 
	
	"Misc.": 
	{"idk": {"Cost": 1, "Stock": 100, 
	"Sprite": ["res://Assests/Items/idksprite.png", 18.5],
	"Description": "lorem ipsum or sumthing"}
	, 
	
	"flare or something": {"Cost": 20, "Stock": 10, 
	"Sprite": ["res://Assests/Items/idksprite2.png", 18.5],
	"Description": "you can see a chosen tile. idk why you want that, i can already see it from here"},
	
	"Nuke": {"Cost": 9999, "Stock": 1, 
	"Sprite": ["res://Assests/Items/nukesprite.png", 18.5],
	"Description": "Converts all tiles in a 3-tile radius of the chosen tile into barren tiles. Takes 1 life from any bases in its radius."}
	}
	}
	
func _ready() -> void:
	inventory.get_item_sprite.connect(_get_item_sprite)
	inventory.get_building_info.connect(_get_building_info)
	tile_manager.get_building_info_tile.connect(_get_building_info)

func _get_item_sprite(key, current_category) -> void:
	emit_signal("return_item_sprite", key, item_list[current_category][key]["Sprite"].duplicate(true), current_category)
	
func _get_building_info(action, tile_name, item_name) -> void:
	emit_signal("return_building_info", action, tile_name, item_name, item_list["Buildings"][item_name]["Sprite"], item_list["Buildings"][item_name]["Functionality"], item_list["Buildings"][item_name]["Placement"])
