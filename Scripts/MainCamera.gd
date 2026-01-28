extends Camera2D

var smooth_zoom = 1.0
var target_zoom = 1.0
var target_offset = 0.01 
var original_position_camera = Vector2(0, 0)
var original_position_click = Vector2(0, 0)

var dragging = false
const ZOOM_SPEED = 5
const ZOOM_CHANGE = 1.15

func _process(delta):
	smooth_zoom = lerp(smooth_zoom, target_zoom, ZOOM_SPEED * delta)
	if abs(smooth_zoom - target_zoom) < target_offset:
		smooth_zoom = target_zoom
	zoom = Vector2(smooth_zoom, smooth_zoom)
		
 
func _input(event) -> void:
	if event.is_action_pressed("rightclick"):
		original_position_camera = position
		original_position_click = get_local_mouse_position()
		dragging = true
		position_smoothing_enabled = false
	if dragging:
		position = original_position_camera + (original_position_click - get_local_mouse_position())
		if event is InputEventMouseButton:
			if event.button_mask != 2 && event.button_mask != 3:
				dragging = false
				position_smoothing_enabled = true
				
	if event.is_action_pressed("mousewheelup"):
		zoom = Vector2(target_zoom * ZOOM_CHANGE, target_zoom * ZOOM_CHANGE)
		target_zoom = target_zoom * ZOOM_CHANGE
		
	if event.is_action_pressed("mousewheeldown"):
		zoom = Vector2(target_zoom / ZOOM_CHANGE, target_zoom / ZOOM_CHANGE)
		target_zoom = target_zoom / ZOOM_CHANGE
		
