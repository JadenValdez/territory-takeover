extends Node2D

@onready var inventory: Node2D = $"../UiManager/Inventory"

const phases = {
	"Minigame": ["Selecting Tiles", "Placing Buildings", "Attacking"], 
	"Shop": [], 
	"Conquest": []
}
var current_phase = "Conquest"
var current_action = "Selecting Tiles"

signal set_current_phase
signal set_current_action

func _ready() -> void:
	inventory.set_current_action.connect(_set_current_action)
	emit_signal("set_current_phase", current_phase)
	
func _input(event) -> void:
	if event.is_action_pressed("a"):
		current_phase = "Conquest"
		emit_signal("set_current_phase", current_phase)
	if event.is_action_pressed("s"):
		current_phase = "Shop"
		emit_signal("set_current_phase", current_phase)

func _set_current_phase(phase) -> void:
	current_phase = phase
	emit_signal("set_current_phase", current_phase)

func _set_current_action(action) -> void:
	current_action = action
	emit_signal("set_current_action", current_action)
