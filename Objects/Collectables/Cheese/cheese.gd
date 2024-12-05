extends Area3D

# ---------- VARIABLES ---------- #

# You can change these values from inspector!
@export var follow_speed : float = 6
const follow_ramp_up_speed : float = 0.1  # Faster it becomes while following you over time.
@export var amplitude := 0.2
@export var frequency := 4

var time_passed = 0
var is_in_close_range = false
var is_in_far_range = false
var initial_position := Vector3.ZERO

@onready var player := get_tree().get_first_node_in_group("PlayerCharacter")

# Coin Hover Animation
func coin_hover(delta):
	time_passed += delta
	
	var new_y = initial_position.y + amplitude * sin(frequency * time_passed)
	position.y = new_y

func _on_body_entered(body):
	# Delete The Coin and Add Score
	if body.is_in_group("PlayerCharacter"):
		body.CollectCheese()
		queue_free()
