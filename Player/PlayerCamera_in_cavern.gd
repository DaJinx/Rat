extends Node

@onready var root: Node3D = $".."

@export var follow_lerp_factor : float = 8  # How fast the camera catches up to the player.

var targetPosition:Vector3
var targetRotation
var player

func Tick(pos, rot, play, delta):
	targetPosition = pos
	targetRotation = rot
	player = play
	
	Movement(delta)
	Rotation(delta)

func Movement(delta):
	root.position.x = lerp(root.position.x, root.player.position.x, delta * follow_lerp_factor)
	root.position.z = lerp(root.position.z, targetPosition.z, delta * follow_lerp_factor)
	root.position.y = lerp(root.position.y, targetPosition.y, delta * (follow_lerp_factor * 0.6))

func Rotation(delta):
	root.global_rotation.x = lerp_angle(root.global_rotation.x, 0,   delta * 2)
	root.global_rotation.y = lerp_angle(root.global_rotation.y, targetRotation.y,   delta * 2)
