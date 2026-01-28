extends Node2D

@onready var shop_ui: Node2D = $".."
@onready var shop_item_preview_description_label: Label = $ShopItemPreviewDescriptionLabel
@onready var shop_item_preview_name_label: Label = $ShopItemPreviewNameLabel
@onready var shop_item_preview_stock_label: Label = $ShopItemPreviewStockLabel
@onready var shop_item_tile_background_sprite: Sprite2D = $ShopItemTileBackgroundSprite
@onready var shop_item_sprite: Sprite2D = $ShopItemSprite
@onready var out_of_stock_sprite: Sprite2D = $OutOfStockSprite

var sprite_load

func _ready() -> void:
	shop_ui.set_item_preview.connect(_set_item_preview)
	
func _set_item_preview(item_name, item_stock, item_description, item_sprite) -> void:
	if item_name == "None":
		shop_item_sprite.visible = false
		shop_item_tile_background_sprite.visible = false
		shop_item_preview_name_label.text = ""
		shop_item_preview_stock_label.text = ""
		shop_item_preview_description_label.text = ""
		out_of_stock_sprite.visible = false
	else:
		shop_item_sprite.visible = true
		sprite_load = load(item_sprite[0])
		shop_item_sprite.texture = sprite_load
		shop_item_sprite.scale = Vector2(item_sprite[1], item_sprite[1])
		if item_name != "Nuke" && item_name != "Shield":
			shop_item_tile_background_sprite.visible = true
		else:
			shop_item_tile_background_sprite.visible = false
		shop_item_preview_name_label.text = item_name
		shop_item_preview_stock_label.text = "Stock: " + str(item_stock)
		shop_item_preview_description_label.text = item_description
		if str(item_stock) == "Infinity":
			out_of_stock_sprite.visible = false
		elif item_stock <= 0:
			out_of_stock_sprite.visible = true
		else:
			out_of_stock_sprite.visible = false
