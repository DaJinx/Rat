class_name PlayerStateMachine
extends "player_shared.gd"

var parent_state: PlayerStateMachine # Reference to self for children to call to.

enum states {
	# Movement
	GROUNDED, JUMPING, FALLING, FALL_SQUASHED,
	DASHING_GROUNDED, DASHING_AIR_SHORT, DASHING_AIR_LONG,
	WALL_SLIDE, LEDGE_GRAB, PARAGLIDING,
	
	# Combat based
	ATTACKING, ATTACKING_AIR, GROUND_POUNDING, AIMING_NEEDLE, THROWING_NEEDLE,
	STUNNED, HEALING, DEAD, BLOCKING, PARRY,
	
	# Interaction
	GRAB_HOLD, GRAB_THROW,
	TIGHTROPE, RAIL_GRINDING, GRAPPLING,
	CLIMB_POLE, STAND_ON_POLE,
	SITTING_ON_BENCH, IN_SLINGSHOT, SLINGSHOT_LAUNCHED
	}
@export var currentState : states
var isDefaultState = false

#@onready var Player: PlayerCharacter = $".."

@onready var grappling: Node = $Grappling
@onready var shared: Node = $"../Shared"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SetToDefaultState()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if !Player.controlled:
		return
	
	
	print("State: ", states.keys()[currentState])
	
	# On the ground, idle or moving
	if currentState == states.GROUNDED:
		Movement.Move(delta)
		Movement.Gravity(delta)
		Player.WalkVibrations()
	
	# Holding jump
	elif currentState == states.JUMPING:
		Movement.Move(delta)
		Movement.Gravity(delta)
		Player.velocity.y = Movement.jump_strength
		Movement.DetectWall()
		$Grappling.SearchNearGrapplePoints()
		Player.animation.play("Jump", 0.5)
	
	# In the air and NOT jumping.
	elif currentState == states.FALLING:
		Movement.Move(delta)
		Movement.DetectWall()
		Movement.Gravity(delta)
		Health.OffStageCheck()
		$Grappling.SearchNearGrapplePoints()
		Player.animation.play("Fall", 0.5, 0.1)
	
	elif currentState == states.DASHING_GROUNDED:
		pass
	
	elif Combat.lockedOn:
		if currentState == states.ATTACKING:
			pass
		
		elif currentState == states.BLOCKING:
			Player.velocity = Vector3.ZERO
			Movement.Gravity(delta)
	
	elif currentState == states.LEDGE_GRAB:
		Movement.HoldingLedge(delta)
	
	elif currentState == states.WALL_SLIDE:
		Movement.WallSlide()
	
	elif currentState == states.GRAPPLING:
		$StateMachine/Grappling.ManualProcess()
	
	elif currentState == states.PARAGLIDING:
		Movement.Move(delta)
		Player.velocity.y = -2
		
		if Player.is_on_floor():
			Movement.Landed()
	
	elif currentState == states.SLINGSHOT_LAUNCHED:
		Movement.Gravity(delta)
	
	elif currentState == states.ATTACKING:
		pass
	
	elif currentState == states.BLOCKING:
		Player.velocity = Vector3.ZERO
		#Movement.Move(delta)
		Movement.Gravity(delta)
		#Player.WalkVibrations()
	
	elif currentState == states.GROUND_POUNDING:
		Player.velocity = Vector3.ZERO
		Movement.gravity += Combat.groundPound_OverTimeStrength
		Movement.Gravity(delta)
	
	elif currentState == states.CLIMB_POLE:
		pass
	
	elif currentState == states.FALL_SQUASHED:
		Movement.Move(delta)

func DefaultStates():
	return
	if currentState == states.GROUNDED  or  currentState == states.FALLING:
		
		isDefaultState = true
		
		if Player.is_on_floor():
			currentState = states.GROUNDED
		else:
			currentState = states.FALLING
	
	else:
		isDefaultState = false

# If youre on a different state and you wanna go to the appropriate default state.
func SetToDefaultState():
	if Player.is_on_floor():
		currentState = states.GROUNDED
	else:
		currentState = states.FALLING
	
	isDefaultState = true

# Input pressed jump during "GRAPPLING"
func GrappleJump():
	grappling.GrappleJumpOff()
