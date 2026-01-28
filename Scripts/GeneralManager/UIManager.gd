extends CanvasLayer

signal set_current_player

@onready var player_manager: Node2D = $"../PlayerManager"

var player_list = [
	#[Player, Action]
	[ "Player", "z"],
	[ "Enemy" , "x"], 
	[ "Rival" , "c"]
	]


func _ready() -> void:
	player_manager.set_current_player.connect(_set_current_player)
	
func _set_current_player(current_player) -> void:
	emit_signal("set_current_player", current_player)
#make sidebar ui telling current player, remaining attacks, maybe stats
#make another ui on the right that shows player order during the conquest phase, with plauer color and # of attacks
