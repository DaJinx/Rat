extends Node

@onready var root: Node3D = $".."
@export var follow_lerp_factor : float = 5  # How fast the camera catches up to the player.

var player
var playerPos
var lockedOnTarget
var moveDistance:Vector3


func Tick(target, newPlayer, delta):
	lockedOnTarget = target
	player = newPlayer
	playerPos = player.global_position
	
	Movement(delta)
	Rotation(delta)


func Movement(delta):
	var fwValue = root.player.mesh.get_global_transform().basis.z * 0.7
	
	if Math.IsMoving(player.velocity):
		moveDistance = lerp( moveDistance, fwValue, 0.02)
	else:
		moveDistance = lerp( moveDistance, Vector3.ZERO, 0.025)
	
	root.position.x = playerPos.x + moveDistance.x
	root.position.z = playerPos.z + moveDistance.z
	
	if root.followPlayerY:
		root.position.y = lerp(root.position.y,  playerPos.y + 0.02,  delta * (follow_lerp_factor * 0.3))
	
	# Stop is from escaping from the player.
	const maxVertDistance = 3
	root.global_position.y = clamp(
		root.global_position.y,
		player.global_position.y - maxVertDistance,
		player.global_position.y + maxVertDistance)


func Rotation(delta):
	#root.look_at(lockedOnTarget.global_position)
	
	var speed = 25
	var new_transform = root.transform.looking_at(lockedOnTarget.global_position, Vector3.UP)
	root.transform  = root.transform.interpolate_with(new_transform,  speed * delta)
