extends Node2D

@onready var tile_manager: Node2D = $"../../TileManager"
@onready var tile_info_label: Label = $TileInfoLabel
@onready var tile_info_label_id: Label = $TileInfoLabel_ID
@onready var tile_info_tooltip: Node2D = $"."

var current_tile_id = ""
var current_tile_owner = ""
var current_tile_status = ""
var current_tile_lives = 1
var current_tile_color = [1, 1, 1]

func _ready() -> void:
	tile_manager.show_tile_info.connect(_show_tile_info)
	tile_manager.hide_tile_info.connect(_hide_tile_info)
	tile_manager.update_tile_tooltip.connect(_update_tile_tooltip)
	
	tile_info_label.modulate = Color(1, 1, 1)
	tile_info_label_id.modulate = Color(1, 1, 1)
	tile_info_tooltip.visible = false

func _show_tile_info(tile_info) -> void:
	current_tile_id = tile_info["ID"]
	current_tile_owner = tile_info["Owner"]
	current_tile_status = tile_info["Status"]
	current_tile_lives = tile_info["Lives"]
	current_tile_color = tile_info["Color"]
	_show_tooltip()
	
func _hide_tile_info(tile_info) -> void:
	if tile_info["ID"] == current_tile_id:
		_hide_tooltip() 

func _show_tooltip() -> void:
	tile_info_label_id.text = current_tile_id
	tile_info_label_id.modulate = Color(current_tile_color[0], current_tile_color[1], current_tile_color[2])
	
	tile_info_label.text = "Owner: " + current_tile_owner + "
	Status: " + current_tile_status + "
	Lives: " + str(current_tile_lives)
	tile_info_tooltip.visible = true

func _hide_tooltip() -> void:
	tile_info_tooltip.visible = false

func _update_tile_tooltip(tile_info) -> void:
	if current_tile_id == tile_info["ID"]:
		_show_tile_info(tile_info)
