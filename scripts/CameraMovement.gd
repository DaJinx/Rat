extends Node3D

# ---------- VARIABLES ---------- #

enum states {
	FOLLOW_PLAYER, LOCKED_ON, CINEMATIC, IN_ROOM, IN_CAVERN
	}
@export var currentState : states = states.FOLLOW_PLAYER
@export var follow_lerp_factor : float = 5  # How fast the camera catches up to the player.

# Assign Camera Node here it might be named different in your Project
@onready var camera = $SpringArm3D/Camera3D
@onready var follow_player: Node = $FollowPlayer
@onready var locked_on: Node = $LockedOn
@onready var in_room: Node = $InRoom
@onready var in_cavern: Node = $InCavern

@onready var player : CharacterBody3D = $".."
var fadingOut:bool = false

var rotationTarget : Vector3 = rotation_degrees
var followPlayerY:bool = true
#var yDeadzone:float = 1 # How far falling from camera/rising up until it just follows the y position anyway.

var targetPosition:Vector3
var targetRotation:Vector3
var wasInCavern:bool = false
var lockedOnTarget

var read = false

# ---------- FUNCTIONS ---------- #

func _ready():
	# Confining Mouse Cursor in the game view so it doesnt get in the way of gameplay
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	global_position = player.global_position

func _process(delta):
	pass
	
	
	
	#if currentState == states.FOLLOW_PLAYER  and  !wasInCavern:
		##rotation_degrees.x = lerp_angle(rotation_degrees.x, rotationTarget.x, 5 * delta)
		#rotation_degrees.x = rotationTarget.x
		#rotationTarget.x = clamp(rotation_degrees.x, -highestPerspective, lowestPerspective)
		#rotation_degrees.x = clamp(rotation_degrees.x, -highestPerspective, lowestPerspective)
		#
		##rotation_degrees.y = lerp_angle(rotation_degrees.y, rotationTarget.y, 1 * delta)
		#rotation_degrees.y = rotationTarget.y
		#rotationTarget.y = wrapf(rotation_degrees.y, 0, 360)
		#rotation_degrees.y = wrapf(rotation_degrees.y, 0, 360)
		
		#print(rotation_degrees.x)
		#print(rotationTarget.x)
	
	#elif currentState == states.FOLLOW_PLAYER  and  wasInCavern:
		#global_rotation.x = lerp_angle(global_rotation.x, rotationTarget.x,   delta * 2)
		#global_rotation.y = lerp_angle(global_rotation.y, rotationTarget.y,   delta * 2)
		#
		#await get_tree().create_timer(2).timeout
		#wasInCavern = false


func _physics_process(delta: float) -> void:
	
	if fadingOut:
		return
	
	
	if currentState == states.FOLLOW_PLAYER:
		follow_player.Tick(delta)
		follow_player.ControllerInputs(delta)
	
	elif currentState == states.LOCKED_ON:
		#if read:
		locked_on.Tick(lockedOnTarget, player, delta)
		#FollowPlayer(delta)
	
	elif currentState == states.IN_ROOM:
		in_room.Tick(targetPosition, targetRotation, player, delta)
	
	elif currentState == states.IN_CAVERN:
		in_cavern.Tick(targetPosition, targetRotation, player, delta)

func _input(event: InputEvent):
	if currentState == states.FOLLOW_PLAYER:
		follow_player.MouseInputs(event)





func PlayerJumped():
	followPlayerY = false

func PlayerLanded():
	followPlayerY = true

func EnterRoom(pos, rot):
	#fadingOut = true
	currentState = states.IN_ROOM
	targetPosition = pos
	
	global_rotation.y = rot.y
	rotation_degrees.x = -20
	
	print("TELE")
	
	await get_tree().create_timer(0.5).timeout
	#fadingOut = false

func ExitRoom():
	currentState = states.FOLLOW_PLAYER
	global_position = player.global_position # Skip the lerp

func EnterCavern(pos, rot):
	currentState = states.IN_CAVERN
	targetPosition = pos
	targetRotation = rot
	#cavernBasis = rot

func ExitCavern():
	rotationTarget = rotation_degrees
	currentState = states.FOLLOW_PLAYER

func LockOn(target):
	if target: # Is valid
		EnableLock(target)
	else:
		DisableLock()
	print("LOCK ON: ", target)

func EnableLock(target):
	currentState = states.LOCKED_ON
	lockedOnTarget = target
	print("TARGET:  ", lockedOnTarget)
	var tween = get_tree().create_tween()
	tween.tween_property(camera, "fov", 65, 0.2)
	
	# Quick smooth blend between targets
	#var tween2 = get_tree().create_tween()
	#tween.tween_property(self, "look_at", lockedOnTarget.global_position, 0.00001)

func DisableLock():
	follow_player.rotationTarget = rotation_degrees # Doesnt jump back to what it was previously, sets current to new.
	currentState = states.FOLLOW_PLAYER
	lockedOnTarget = null
	
	var tween = get_tree().create_tween()
	tween.tween_property(camera, "fov", 75, 0.2)

func SwitchCamera(newCam:Camera3D, duration:float):
	GlobalCamera.transitionCamera3D(camera, newCam, duration)
