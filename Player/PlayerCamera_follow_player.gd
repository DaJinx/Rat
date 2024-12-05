extends Node

@onready var root: Node3D = $".."
@export var follow_lerp_factor : float = 5  # How fast the camera catches up to the player.
@export var highestPerspective : float = 60  # How far you can look downwards.
@export var lowestPerspective : float = 70  # How far you can look upwards.
@export var movementDeadzone : float = 2

# Control Sensitivity through inspector or from here
@export var mouse_sensitivity := 0.2
@export var controller_sensitivity := 3

var rotationTarget : Vector3 
var moveForwardValue:float = 0
var moveSideValue:float = 0
var moveDistance:Vector3

func _ready() -> void:
	rotationTarget = root.rotation_degrees

func Tick(delta):
	
	
	
	Movement(delta)
	Rotation(delta)

func Movement(delta):
	# Smoothly follow player's position
	
	#var difference = abs(position.y  - playerPos.y)
	
	#if !followPlayerY:
		#if difference >= 5:
			#followPlayerY = true
		#else:
			#playerPos.y = position.y
	
	# Doesnt move if youre spinning around. A deadzone.
	#var pos = Vector3 (player.position.x, position.y, player.position.z)
	#var differenceXZ = abs(position - pos)
	#if differenceXZ.x < movementDeadzone  and  differenceXZ.z < movementDeadzone:
		#return
	
	var player = root.player
	var rightValue = FollowPlayer_Side(delta)
	var forwardValue = FollowPlayer_Forward(delta)
	#var playerPos = player.position + ((rightValue + forwardValue) / 2)
	#var playerPos = player.position + rightValue
	var playerPos = player.position
	
	
	
	var fwValue = player.mesh.get_global_transform().basis.z * 0.7
	
	if Math.IsMoving(player.velocity):
		moveDistance = lerp( moveDistance, fwValue, 0.02)
	else:
		moveDistance = lerp( moveDistance, Vector3.ZERO, 0.025)
	
	root.position.x = playerPos.x + moveDistance.x
	root.position.z = playerPos.z + moveDistance.z
	
	#position.x = lerp(position.x, playerPos.x, delta * follow_lerp_factor)
	#position.z = lerp(position.z, playerPos.z, delta * follow_lerp_factor)
	root.position.y = lerp(root.position.y, playerPos.y, delta * (follow_lerp_factor * 0.6))
	
	# Stop is from escaping from the player.
	const maxHorDistance = 0.5
	const maxVertDistance = 3
	#global_position.x = clamp(
		#global_position.x,
		#player.global_position.x - maxHorDistance,
		#player.global_position.x + maxHorDistance)
	#global_position.z = clamp(
		#global_position.z,
		
		#player.global_position.z - maxHorDistance,
		#player.global_position.z + maxHorDistance)
	root.global_position.y = clamp(
		root.global_position.y,
		player.global_position.y - maxVertDistance,
		player.global_position.y + maxVertDistance)


func FollowPlayer_Side(delta):
	var playerPos = root.player.position
	var rightAxis = root.get_global_transform().basis.x
	var desiredSideValue = Input.get_axis("move_left", "move_right") * 4
	var movementSideAddition
	
	if desiredSideValue != 0:
		
		## If turning around (e.g. going left then turn right), the lerp will speed up drastically to
		## not slowly catch up to the other side's full length, feeling sluggish.
		if (desiredSideValue > 0 and moveSideValue < 0)   or   (desiredSideValue < 0 and moveSideValue > 0):
			moveSideValue = lerpf(moveSideValue,   desiredSideValue,   20 * delta)
		else:
			moveSideValue = lerpf(moveSideValue,   desiredSideValue,   0.5 * delta)
		
		movementSideAddition = rightAxis * moveSideValue
	
	else:
		moveSideValue = lerpf(moveSideValue,   0.0,   3 * delta)
		movementSideAddition = rightAxis * moveSideValue
	
	return movementSideAddition


func FollowPlayer_Forward(delta):
	var playerPos = root.player.position
	var forwardAxis = -root.get_global_transform().basis.z
	var desiredForwardValue = Input.get_axis("move_up", "move_down") * 3
	desiredForwardValue = clampf(desiredForwardValue, -3, 1)
	var movementForwardAddition
	
	if Math.IsMoving(root.player.velocity):
		
		## If turning around (e.g. going left then turn right), the lerp will speed up drastically to
		## not slowly catch up to the other side's full length, feeling sluggish.
		if (desiredForwardValue > 0 and moveSideValue < 0)   or   (desiredForwardValue < 0 and moveSideValue > 0):
			moveForwardValue = lerpf(moveSideValue,   desiredForwardValue,   20 * delta)
		else:
			moveForwardValue = lerpf(moveSideValue,   desiredForwardValue,   0.1 * delta)
		
		movementForwardAddition = forwardAxis * moveForwardValue
	
	else:
		moveSideValue = lerpf(moveSideValue,   0.0,   2.5 * delta)
		movementForwardAddition = forwardAxis * moveForwardValue
	
	#print("Ramble: ", moveSideValue)
	
	return movementForwardAddition


func Rotation(delta):
	root.rotation_degrees.x = rotationTarget.x
	root.rotationTarget.x = clamp(root.rotation_degrees.x, -highestPerspective, lowestPerspective)
	root.rotation_degrees.x = clamp(root.rotation_degrees.x, -highestPerspective, lowestPerspective)
	
	#rotation_degrees.y = lerp_angle(rotation_degrees.y, rotationTarget.y, 1 * delta)
	root.rotation_degrees.y = rotationTarget.y
	rotationTarget.y = wrapf(root.rotation_degrees.y, 0, 360)
	root.rotation_degrees.y = wrapf(root.rotation_degrees.y, 0, 360)


## Inputs
func ControllerInputs(delta):
	var rot := Vector3.ZERO
	rot.x = Input.get_axis("camera_down", "camera_up")
	rot.y = Input.get_axis("camera_right", "camera_left")
	rot *= controller_sensitivity
	
	rotationTarget += Vector3(rot.x, rot.y, 0)
	#rotationTarget = rotation_degrees + Vector3(rot.x, rot.y, 0)

func MouseInputs(event):
	if event is InputEventMouseMotion:
		rotationTarget.x -= event.relative.y * mouse_sensitivity
		rotationTarget.y -= event.relative.x * mouse_sensitivity
	print("Mouse: ", event)
