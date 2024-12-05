#extends "player_state_machine.gd"
extends Node

enum grappleStates {  NOT_GRAPPLING, GRAPPLE_SWINGING, SHOOTING_HOOK, RETURNING_HOOK  }
@export var currentGrappleState : grappleStates = grappleStates.NOT_GRAPPLING

@onready var Player: CharacterBody3D = $"../.."

var grapplePoints = []
var grapplePoint:Object
var grapplePos:Vector3
var canHook:bool = false
var hooked:bool = false

var grappleHookClimbInput:float = 0.0
const climbSpeed = 0.2

const topDetatches:bool = false
const floorDetatches:bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if currentGrappleState == grappleStates.NOT_GRAPPLING:
		pass
		# Check for points?
	
	elif currentGrappleState == grappleStates.GRAPPLE_SWINGING:
		GrappleSwing()
	
	elif currentGrappleState == grappleStates.SHOOTING_HOOK:
		pass
	
	elif currentGrappleState == grappleStates.RETURNING_HOOK:
		pass

func SearchNearGrapplePoints():
	if hooked  or  grapplePoints.is_empty():
		return
	
	#for i in grapplePoints:
		## Check if they have a function to enable the icon. Then disable it.
		#print("Apple: ", grapplePoints[i] )
		#if grapplePoints[i].has_method("EnableIcon"):
			#grapplePoints[i].EnableIcon(false)
	
	grapplePoints.clear
	grapplePos = Vector3.ZERO
	canHook = false
	
	## Get closest grapple point.
	
	## Sphere trace towards the point see if anything is in the way.
	
	# Set can hook
	## Temp use 0, can find the closest on a later date.
	if grapplePoints[0].has_method("EnableIcon"):
			grapplePoints[0].EnableIcon(true)
	canHook = true
	grapplePoint = grapplePoints[0]
	grapplePos = grapplePoint.global_position
	
	print("Apple: ", grapplePos)

func LaunchingHook():
	pass
	#if :
		#HookedAction()

func HookedAction():
	if grapplePoint.has_method("Attached"):
			## Get previous velocity
			grapplePoint.Attached(self)
			hooked = true
			## Continue velocity
			## Reduce air control
			currentGrappleState = grappleStates.GRAPPLE_SWINGING

func GrappleSwing():
	# Jump off if at the very top.
	if topDetatches  and  Player.global_position.distance_to(grapplePos) <= 0.25:
		DetachGrapple()
		Player.gravity = -10
	
	GrappleClimbUpDown()
	GrappleCheckForWall()
	GrappleCheckForFloor()

func GrappleClimbUpDown():
	# Input
	grappleHookClimbInput = 0
	if Input.is_action_pressed("attack"):
		grappleHookClimbInput += 1
	if Input.is_action_pressed("dash"):
		grappleHookClimbInput -= 1
	
	if grappleHookClimbInput == 0:
		return
	
	# Movement
	## Detatch from point
	Player.global_position += Math.UpVector(self) * (climbSpeed * grappleHookClimbInput)
	## Re-attach to point

func GrappleCheckForWall():
	pass

func GrappleCheckForFloor():
	pass

func DetachGrapple():
	hooked = false
	
	## Set air control back to normal.
	## Set rotation back to normal.
	## Detach from point
	
	grapplePoint = null

func GrappleJumpOff():
	if currentGrappleState != grappleStates.GRAPPLE_SWINGING:
		return
		# If not started swinging or already returning, dont do anything. 
	DetachGrapple()
	Player.gravity = -10
	Player.velocity = Math.ForwardVector(self) * 10

func PullInRope():
	pass

func _on_grapple_points_entered(area: Area3D) -> void:
	if area.get_parent().name == "GrappleHookPoint":
		grapplePoints.append(area.get_parent())

func _on_grapple_points_exited(area: Area3D) -> void:
	if area.get_parent().name == "GrappleHookPoint":
		grapplePoints.erase(area.get_parent())
