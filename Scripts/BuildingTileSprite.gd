extends Sprite2D

var sprite_num = 0
@onready var tile: Node2D = $".."
var target_position = Vector2(0, 0)
var sprite_load
var moving = false

func _ready() -> void:
	tile.add_item_sprite.connect(_add_item_sprite)
	tile.remove_item_sprite.connect(_remove_item_sprite)
	tile.set_building_positions.connect(_set_building_positions)
	moving = false
	set_process(false)
	
func _add_item_sprite(current_building_num, item_sprite) -> void:
	if current_building_num == sprite_num:
		sprite_load = load(item_sprite[0])
		texture = sprite_load
		scale = Vector2(item_sprite[1]/5.0, item_sprite[1]/5.0)
		
func _remove_item_sprite(current_building_num) -> void:
	if current_building_num + 1 == sprite_num:
		texture = null
	
func _set_building_positions(building_positions) -> void:
	for n in range(building_positions.size()):
		if n + 1 == sprite_num:
			target_position = building_positions[n]
			moving = true
			set_process(true)

func _process(_delta: float) -> void:
	if moving == true:
		position = position.lerp(target_position, 0.2)
		if abs(position - target_position).x < 0.1 && abs(position - target_position).y < 0.1:
			position = target_position
			set_process(false)
