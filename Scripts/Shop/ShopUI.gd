extends Node2D

signal set_stats
signal set_potential_stats
signal show_stat_tooltip
signal hide_stat_tooltip
signal set_current_category
signal set_item_page
signal set_item_preview
signal set_current_item_window
signal show_next_stat_preview
signal hide_next_stat_preview
signal show_category_tooltip
signal hide_category_tooltip
signal update_player_shop
signal update_item_tab_stock
signal update_inventory

signal open_shop
signal close_shop

@onready var ui_manager: CanvasLayer = $".."

const stat_block = preload("res://Scenes/Shop/StatBlock.tscn")
const stat_shop_label = preload("res://Scenes/Shop/StatShopLabel.tscn")
const shop_stats_button = preload("res://Scenes/Shop/ShopStatsButton.tscn")
const stat_shop_hover = preload("res://Scenes/Shop/StatShopHover.tscn")
const SHOP_ITEM_TAB = preload("res://Scenes/Shop/ShopItemTab.tscn")
const SHOP_ITEM_WINDOW = preload("res://Scenes/Shop/ShopItemWindow.tscn")

@onready var buy_item: Node2D = $BuyItem
@onready var coins_label: Label = $CoinsLabel
@onready var confirm_stats: Node2D = $ConfirmStats
@onready var reset_stats: Node2D = $ResetStats
@onready var shop_button: Node2D = $"../ButtonUI/ShopButton"

var player = {
	"Name": "None", 
	"Base": "00", 
	"Territory": [], 
	"Color": [1, 1, 1], 
	"Stats": {
		"Attack": 1,
		"Defense": 1,
		"Energy": 1,
		"Speed": 1,
		"Technology": 1,
		"Luck": 1,
		}, 
	"Coins": 0, 
	"Inventory": {
		"Buildings" : {},
		"Boosts" : {},
		"Conquest" : {},
		"Misc." : {}
		},
	"Status": "Alive"
	}
var stat_names = ["Attack", "Defense", "Energy", "Speed", "Technology", "Luck"]
var stat_names_short = ["ATK", "DEF", "ENR", "SPD", "TEC", "LCK"]
var starting_prices = {
		"Attack": 5.0,
		"Defense": 10.0,
		"Energy": 1.0,
		"Speed": 10.0,
		"Technology": 50.0,
		"Luck": 25.0,
		}
var cost_scaling = {
		"Attack": 2.0,
		"Defense": 2.0,
		"Energy": 3.0,
		"Speed": 1.4,
		"Technology": 5.0,
		"Luck": 2.0,
		}
var current_stats = {
		"Attack": 1,
		"Defense": 1,
		"Energy": 1,
		"Speed": 1,
		"Technology": 1,
		"Luck": 1,
		}
var buying_stats = {
		"Attack": 1,
		"Defense": 1,
		"Energy": 1,
		"Speed": 1,
		"Technology": 1,
		"Luck": 1,
		}
var current_coins = 0
var potential_coins = 0
var current_inventory = {
	"Buildings" : {},
	"Boosts" : {},
	"Conquest" : {},
	"Misc." : {}
	}
var price = 0
var index = 0
var block_placement = 1

var category_names = ["Buildings", "Boosts", "Conquest", "Misc."]
var items = {
	"Buildings": 
	{"Fort": {"Cost": 50, "Stock": "Infinity", 
	"Sprite": ["res://Assests/Items/fortsprite.png", 5],
	"Description": "Will add 1 life to the tile it is placed on."}
	}
	, 
	
	"Boosts": 
	{"Shield": {"Cost": 200, "Stock": 10, 
	"Sprite": ["res://Assests/Items/shieldsprite.png", 18.5],
	"Description": "Gives you +1 Defense during this Conquest Phase."}
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
	
var current_item_name = "Item"
var current_item_cost = 0
var current_item_stock = 0
var current_item_description = ""
var current_item_sprite = ""
var current_item_category = ""
var node_position = Vector2(0, 0)

func _ready() -> void:
	ui_manager.set_current_player.connect(_set_current_player)
	confirm_stats.confirm_stats_shop.connect(_confirm_stats_shop)
	reset_stats.reset_stats_shop.connect(_reset_stats_shop)
	buy_item.buy_item.connect(_buy_item)
	shop_button.open_shop.connect(_open_shop)
	shop_button.close_shop.connect(_close_shop)
	_make_shop_ui()

func _make_shop_ui() -> void:
	for s in range(stat_names.size()):
		for b in range(5):
			block_placement = b + 1
			var instance_stat_block = stat_block.instantiate()
			instance_stat_block.stat_name_id = stat_names[s]
			instance_stat_block.block_placement = block_placement
			instance_stat_block.current_value = 0
			
			instance_stat_block.position = Vector2(block_placement * 20 + 127, s * 65 + 145)
			instance_stat_block.scale = Vector2(0.5, 0.5)
			add_child(instance_stat_block)
			
			var instance_stat_shop_label = stat_shop_label.instantiate()
			instance_stat_shop_label.text = stat_names_short[s]
			instance_stat_shop_label.position = Vector2(60, s * 65 + 147)
			add_child(instance_stat_shop_label)
			
			var instance_shop_stats_button = shop_stats_button.instantiate()
			instance_shop_stats_button.stat_name = stat_names[s]
			instance_shop_stats_button.position = Vector2(252, s * 65 + 153)
			instance_shop_stats_button.scale = Vector2(0.5, 0.5)
			instance_shop_stats_button.check_if_can_add_buy.connect(_check_if_can_add_buy)
			instance_shop_stats_button.check_if_can_subtract_buy.connect(_check_if_can_subtract_buy)
			instance_shop_stats_button.show_next_stat_preview.connect(_show_next_stat_preview)
			instance_shop_stats_button.hide_next_stat_preview.connect(_hide_next_stat_preview)
			add_child(instance_shop_stats_button)
			
			var instance_stat_shop_hover = stat_shop_hover.instantiate()
			instance_stat_shop_hover.stat_name = stat_names[s]
			instance_stat_shop_hover.position = Vector2(72, s * 65 + 135)
			instance_stat_shop_hover.show_stat_tooltip.connect(_show_stat_tooltip)
			instance_stat_shop_hover.hide_stat_tooltip.connect(_hide_stat_tooltip)
			add_child(instance_stat_shop_hover)
			
	for i in range(category_names.size()):
		var instance_SHOP_ITEM_TAB = SHOP_ITEM_TAB.instantiate()
		instance_SHOP_ITEM_TAB.category_name = category_names[i]
		instance_SHOP_ITEM_TAB.position = Vector2(360, i * 92 + 152)
		#instance_SHOP_ITEM_TAB.set_item_page.connect(_set_item_page)
		instance_SHOP_ITEM_TAB.set_current_category.connect(_set_current_category)
		#instance_SHOP_ITEM_TAB.set_current_item_window.connect(_set_current_item_window)
		#instance_SHOP_ITEM_TAB.show_category_tooltip.connect(_show_category_tooltip)
		#instance_SHOP_ITEM_TAB.hide_category_tooltip.connect(_hide_category_tooltip)
		add_child(instance_SHOP_ITEM_TAB)
	
	for i in range(3):
		var instance_SHOP_ITEM_WINDOW = SHOP_ITEM_WINDOW.instantiate()
		instance_SHOP_ITEM_WINDOW.position = Vector2(472, 116 * i + 150)
		instance_SHOP_ITEM_WINDOW.window_id = i
		instance_SHOP_ITEM_WINDOW.scale = Vector2(0.5, 0.5)
		instance_SHOP_ITEM_WINDOW.set_item_preview.connect(_set_item_preview)
		instance_SHOP_ITEM_WINDOW.set_current_item_window.connect(_set_current_item_window)
		add_child(instance_SHOP_ITEM_WINDOW)
			
func _set_current_player(current_player) -> void:
	player = current_player
	current_stats = player["Stats"].duplicate(true)
	buying_stats = player["Stats"].duplicate(true)
	current_coins = player["Coins"]
	potential_coins = current_coins
	current_inventory = player["Inventory"].duplicate(true)
	_load_player()
	_reset_shop()

func _set_coin_label() -> void:
	coins_label.text = str(potential_coins)
	
func _load_player() -> void:
	_set_coin_label()
	for key in current_stats:
		_set_stats(key, current_stats[key])
	
func _reset_shop() -> void:
	current_item_category = ""
	current_item_name = "None"
	
	emit_signal("hide_category_tooltip")
	emit_signal("set_current_category", "None")
	emit_signal("set_item_page", current_item_category, {})
	emit_signal("set_current_item_window", current_item_name)
	emit_signal("set_item_preview", "None", 0, "Description", "Sprite")
	emit_signal("update_inventory", current_inventory)

func _set_stats(stat_name, stat_value) -> void:
	emit_signal("set_stats", stat_name, stat_value)
	
func _check_if_can_add_buy(stat_name) -> void:
	buying_stats[stat_name] += 1
	price = round(starting_prices[stat_name] * pow(cost_scaling[stat_name], buying_stats[stat_name] - 2))
	if potential_coins >= price:
		potential_coins -= price
		_set_coin_label()
		emit_signal("set_potential_stats", stat_name, buying_stats[stat_name])
	else:
		buying_stats[stat_name] -= 1
		print("You do not have enough money.")
	
func _check_if_can_subtract_buy(stat_name) -> void:
	price = round(starting_prices[stat_name] * pow(cost_scaling[stat_name], buying_stats[stat_name] - current_stats[stat_name] - 1))
	if buying_stats[stat_name] > current_stats[stat_name]:
		potential_coins += price
		buying_stats[stat_name] -= 1
		_set_coin_label()
		emit_signal("set_potential_stats", stat_name, buying_stats[stat_name])
	else:
		print("You cannot go below your currents stats.")
		
func _confirm_stats_shop() -> void:
	for stat_name in stat_names:
		current_stats[stat_name] = buying_stats[stat_name]
		current_coins = potential_coins
		emit_signal("set_stats", stat_name, current_stats[stat_name])
		_update_player_shop()

func _reset_stats_shop() -> void:
	for stat_name in stat_names:
		if buying_stats[stat_name] > current_stats[stat_name]:
			for x in range(buying_stats[stat_name] - current_stats[stat_name]):
				potential_coins += round(starting_prices[stat_name] * pow(cost_scaling[stat_name], buying_stats[stat_name] - x - 2))
			buying_stats[stat_name] = current_stats[stat_name]
			_set_coin_label()
			emit_signal("set_potential_stats", stat_name, buying_stats[stat_name])

func _show_stat_tooltip(stat_name) -> void:
	emit_signal("show_stat_tooltip", stat_name)

func _hide_stat_tooltip(stat_name) -> void:
	emit_signal("hide_stat_tooltip", stat_name)
	
func _show_next_stat_preview(stat_name, action) -> void:
	if action == "Sell" && buying_stats[stat_name] == current_stats[stat_name]:
		emit_signal("hide_next_stat_preview")
	else:
		node_position = Vector2(328, 65 * index + 144)
		if action == "Buy":
			price = round(starting_prices[stat_name] * pow(cost_scaling[stat_name], buying_stats[stat_name] - 1))
		elif action == "Sell":
			price = round(starting_prices[stat_name] * pow(cost_scaling[stat_name], buying_stats[stat_name] - current_stats[stat_name] - 1))
		emit_signal("show_next_stat_preview", price, action, node_position)
	
func _hide_next_stat_preview() -> void:
	emit_signal("hide_next_stat_preview")
	
#func _set_item_page(category_name) -> void:
#	emit_signal("set_item_page", category_name)

func _set_current_category(current_category) -> void:
	current_item_category = current_category
	emit_signal("set_current_category", current_category)
	emit_signal("set_item_page", current_category, items[current_category])
	emit_signal("show_category_tooltip", current_category)
	emit_signal("set_current_item_window", current_item_name)

#func _show_category_tooltip(current_category) -> void:
#	emit_signal("show_category_tooltip", current_category)
	
func _hide_category_tooltip() -> void:
	emit_signal("hide_category_tooltip")
	
func _set_current_item_window(current_item) -> void:
	if current_item == "Current":
		emit_signal("set_current_item_window", current_item_name)
	else:
		emit_signal("set_current_item_window", current_item)
	
func _set_item_preview(item_name, item_cost, item_stock, item_description, item_sprite, item_category) -> void:
	current_item_name = item_name
	current_item_cost = item_cost
	current_item_stock = item_stock
	current_item_description = item_description
	current_item_sprite = item_sprite
	current_item_category = item_category
	emit_signal("set_item_preview", item_name, item_stock, item_description, item_sprite)
	
func _buy_item() -> void:
	if current_item_name == "Item":
		print("No item selected.")
		return
		
	if str(current_item_stock) == "Infinity":
		pass
	elif current_item_stock > 0:
		current_item_stock -= 1
		items[current_item_category][current_item_name]["Stock"] -= 1
	else:
		print("This item is out of stock.")
		return
		
	if potential_coins - current_item_cost < 0:
		print("You cannot afford this item.")
		return
	
	if current_inventory[current_item_category].has(current_item_name):
		current_inventory[current_item_category][current_item_name] = current_inventory[current_item_category][current_item_name] + 1
	else:
		current_inventory[current_item_category][current_item_name] = 1

	current_coins -= current_item_cost
	potential_coins -= current_item_cost
	_set_coin_label()
	emit_signal("set_item_preview", current_item_name, current_item_stock, current_item_description, current_item_sprite)
	emit_signal("update_inventory", current_inventory)
	_update_player_shop()
	
func _update_player_shop() -> void:
	emit_signal("update_player_shop", player["Name"], current_stats, current_coins, current_inventory)
	
func _open_shop() -> void:
	visible = true
	emit_signal("open_shop")
	
func _close_shop() -> void:
	visible = false
	emit_signal("close_shop")
