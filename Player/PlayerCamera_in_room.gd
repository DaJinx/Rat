extends Node

@onready var root: Node3D = $".."

@export var follow_lerp_factor : float = 8  # How fast the camera catches up to the player.

var targetPosition:Vector3
var targetRotation
var player

func Tick(pos, rot, play, delta):
	targetPosition = pos + Vector3(0, 1, 0)
	targetRotation = rot + Vector3(0, 180, 0)
	player = play
	
	Movement(delta)
	Rotation(delta)

func Movement(delta):
	root.position.x = lerp(root.position.x, root.player.position.x, delta * follow_lerp_factor)
	root.position.z = lerp(root.position.z, targetPosition.z, delta * follow_lerp_factor)
	root.position.y = lerp(root.position.y, targetPosition.y, delta * (follow_lerp_factor * 0.6))

func Movement2(delta):
	root.position.x = lerp(root.position.x, root.player.position.x, delta * follow_lerp_factor)
	root.position.z = lerp(root.position.z, root.player.position.z, delta * follow_lerp_factor)
	root.position.y = lerp(root.position.y, root.player.position.y, delta * (follow_lerp_factor * 0.6))

func Rotation(delta):
	#root.global_rotation.x = lerp_angle(root.global_rotation.x, 0,   delta * 2)
	#root.global_rotation_degrees.y = lerp_angle(root.global_rotation_degrees.y, targetRotation.y,   delta * 2)
	
	root.global_rotation_degrees.x = -20
	root.global_rotation_degrees.y = targetRotation.y
	
	#var target = Vector3(player.global_position.x,  targetPosition.y - 3,  player.global_position.z)
	#var speed = 5
	#var new_transform = root.transform.looking_at(target, Vector3.UP)
	#root.transform  = root.transform.interpolate_with(new_transform,  speed * delta)
	#root.global_rotation_degrees.y = targetRotation.y
	#root.global_rotation_degrees.z = 0
