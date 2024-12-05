extends Camera2D

var player
var active:bool = false

func Activate(activePlayer):
	player = activePlayer
	active = true

func _physics_process(delta: float) -> void:
	if !active:
		return
	
	global_position = player.global_position
