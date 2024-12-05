extends Node3D

@onready var locRot : Node3D = $LocRot
var isInside : bool = false
var slingshotPercentage : float = 0
var playerRef 
var cooldownActive : bool = false
var targetRotation : Vector3


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if !isInside:
		return
	
	
	# Launch
	if Input.is_action_pressed("jump"):
		Launch()
	
	
	# Move
	if Input.is_action_pressed("move_down"):
		slingshotPercentage += 0.015
	else:
		slingshotPercentage -= 0.15
	slingshotPercentage = clampf(slingshotPercentage, 0, 4)
	locRot.position.z = slingshotPercentage
	print("Slingshot Percentage: ", slingshotPercentage)
	playerRef.position = locRot.global_position
	
	
	# Aiming
	var aimInput := Vector2.ZERO
	aimInput.x = Input.get_axis("camera_down", "camera_up")  # Height
	aimInput.y = Input.get_axis("camera_right", "camera_left")  # Direction
	aimInput *= 3 # Sensitivity
	targetRotation += Vector3(aimInput.x, aimInput.y, 0)
	targetRotation.x = clampf(targetRotation.x, -180, 180)
	targetRotation.y = clampf(targetRotation.y, -180, 180)
	locRot.rotation_degrees.x = targetRotation.x
	locRot.rotation_degrees.y = targetRotation.y
	locRot.position.x = targetRotation.y * 30
	
	
	# Set location and rotation
	playerRef.position = locRot.global_position
	playerRef.rotation_degrees.x = locRot.global_rotation_degrees.x
	playerRef.rotation_degrees.y = locRot.global_rotation_degrees.y


func _on_area_3d_body_entered(body: Node3D) -> void:
	if cooldownActive:
		return
	
	if body.has_method("EnterSlingshot"):
		body.EnterSlingshot(locRot.global_position, global_rotation_degrees.y)
		isInside = true
		playerRef = body

func Launch():
	isInside = false
	if playerRef.has_method("LaunchFromSlingshot"):
		cooldownActive = true
		var strength = slingshotPercentage * 4
		playerRef.LaunchFromSlingshot(strength, Vector3.ZERO)
		await get_tree().create_timer(1).timeout
		cooldownActive = false
