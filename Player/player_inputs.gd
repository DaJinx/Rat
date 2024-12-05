class_name PlayerInputs
extends "player_shared.gd"

#@onready var Player: PlayerCharacter = $".."

#region MOVEMENT
@export_subgroup("Movement")
var rawMovementInput : Vector3
var movementInput : Vector3
var moveInputLastFrame : Vector3
#endregion

#region JUMPING
@export_subgroup("Jumping")
var is_just_jumping := false
var jumpButtonHeldValue : float = 0
#endregion

var inputDashHeld : bool = false
const inputDashHeldMax : int = 10 # How many frames max until youve considered the held state.
var inputDashHeldTime : int = 0 # How many frames currently held for.

var blockOverDash

const photoCamRef:= preload("res://Player/PhotoModeCamera.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
# Use physics process, _input is played multiple times a frame and causes negative effects.
func _physics_process(delta: float) -> void:
	if !Player.controlled  or  Health.dead:
		return
	
	MovementInputs(delta)
	JumpInput()
	
	if Player.StateMachine.isDefaultState:
		DashInput(delta)
	
	AttackInput()
	LockOnInput()
	
	#if Input.is_action_pressed("block"):
		#StateMachine.currentState = StateMachine.states.BLOCKING
		#$"../BlockDisplay".visible = true
	#else:
		#StateMachine.currentState = StateMachine.states.GROUNDED
		#$"../BlockDisplay".visible = false
	
	#if Input.is_action_just_pressed("pause"):
		#var PhotoCam = photoCamRef.instantiate()
		#owner.owner.add_child(PhotoCam)
		#PhotoCam.Activate(owner, %Camera3D)
	#
	moveInputLastFrame = movementInput



func MovementInputs(delta):
	# Controller: Left Thumbstick
	# Keyboard: WASD
	
	#if !is_instance_valid(Player.camera):
		#return
	
	rawMovementInput = Vector3.ZERO
	rawMovementInput.x = Input.get_axis("move_left", "move_right")
	rawMovementInput.z = Input.get_axis("move_up", "move_down")
	movementInput = rawMovementInput.rotated(Vector3.UP, Camera.rotation.y).normalized()
	#print(movementInput)
	#print(movementInput * movement_speed * delta)
	
	Movement.movement_velocity = movementInput * Movement.movement_speed * delta
	#velocity = movementInput * movement_speed * delta
	
	
	# Turn
	if moveInputLastFrame != Vector3.ZERO  and  Movement.force == 1:
		var inputDif = (moveInputLastFrame - movementInput).length()
		#inputDif = abs(inputDif)
		
		#print("Input Dif: ", inputDif)
		print("Input Dif: ", Player.mesh.rotation_degrees.y - Movement.degreesLastFrame)
		
		if inputDif > 0.8: # 1 is the highest value of the exact oppiset side
			print("Turn")
	
	
	#var v = velocity.normalized()
	##print("turn 1", v)
	#var f = (movement_velocity*force).normalized()
	##print("turn 2", f)
	#var d = v.dot(f)
	#print("turn 0  ", v, "  ", f, "   ", d)
	#if d < 0:
		#print("turn")


func JumpInput():
	# Controller: Bottom Face Button / Right Bumper
	# Keyboard: Spacebar
	
	var holdingJump = Input.is_action_pressed("jump")
	is_just_jumping = Input.is_action_just_pressed("jump") and get_window().has_focus()
	
	## Jumping
	if is_just_jumping:
		
		if StateMachine.currentState == StateMachine.states.GROUNDED  and  (Player.is_on_floor()  or  Movement.coyoteActive):
			#if !Combat.lockedOn:
				#Movement.JumpStart()
				#Movement.Jump()
			#else:
				#Movement.JumpCombat()
			
			Movement.JumpStart()
			Movement.Jump()
		
		elif StateMachine.currentState == StateMachine.states.DASHING_GROUNDED:
			Movement.JumpStart()
			Movement.LongJump()
		
		elif StateMachine.currentState == StateMachine.states.WALL_SLIDE:
			#ledgeGrabCooldown = true
			Movement.WallJump()
			#await get_tree().create_timer(0.8).timeout
			#ledgeGrabCooldown = false
		
		elif StateMachine.currentState == StateMachine.states.LEDGE_GRAB:
			Movement.DetatchLedge()
		
		elif StateMachine.currentState == StateMachine.states.PARAGLIDING:
			StateMachine.currentState = StateMachine.states.FALLING
			Player.paraglider.visible = false
		
		elif !Player.is_on_floor()  and  Player.hasParaglider:
			StateMachine.currentState = StateMachine.states.PARAGLIDING
			Player.paraglider.visible = true
		
		elif StateMachine.currentState == StateMachine.states.RAIL_GRINDING:
			Player.LeaveGrindRail()
		
		elif StateMachine.currentState == StateMachine.states.SITTING_ON_BENCH:
			Player.JumpOffBench()
		
		elif StateMachine.currentState == StateMachine.states.GRAPPLING:
			StateMachine.GrappleJump()
		
		# Jump buffer for jumping right before landing.
		elif StateMachine.currentState == StateMachine.states.FALLING:
			Movement.jumpBufferActive = true
			await get_tree().create_timer(Movement.jumpBuffer).timeout
			Movement.jumpBufferActive = false
	
	# Still holding
	# The first holding jump tick is done above. To not conflict this with the other jump types.
	if StateMachine.currentState == StateMachine.states.JUMPING and !is_just_jumping and holdingJump:
		Movement.Jump()
	
	# No longer holding
	if StateMachine.currentState == StateMachine.states.JUMPING  and !holdingJump:
		StateMachine.currentState = StateMachine.states.FALLING  # Stops the player from being able to let go then continue.
		Movement.jumping_max_time_timer.stop()
		print("_JUMP NO LONGER INPUT")


# Stuff like grapple hooks, interact, pickup/drop, etc.
func DashInput(delta):
	# Controller: Right Face Button / Left Trigger
	# Keyboard: L Shift
	
	if Combat.lockedOn:
		if Input.is_action_just_pressed("dash"):
			Movement.CombatDash(delta)
	
	
	if Input.is_action_just_pressed("dash"):
		if movementInput == Vector3.ZERO:
			StateMachine.currentState = StateMachine.states.BLOCKING
			$"../BlockDisplay".visible = true
			blockOverDash = true
			print("PPPPPP")
			return
		else:
			inputDashHeld = true
	
	if blockOverDash:
		if Input.is_action_just_released("dash"):
			StateMachine.currentState = StateMachine.states.GROUNDED
			$"../BlockDisplay".visible = false
			blockOverDash = false
	elif inputDashHeld and !blockOverDash:
		DashHeld(delta)

func DashHeld(delta):
	if Input.is_action_pressed("dash"):
		inputDashHeldTime += 1
	
	# Release = is tap.
	if Input.is_action_just_released("dash")  and  inputDashHeldTime < inputDashHeldMax  and  inputDashHeld == true:
		print("Dash Tap:  ", inputDashHeldTime)
		inputDashHeldTime = 0
		inputDashHeld = false
		
		if Player.is_on_floor() and !Movement.dashCooldownActive:
			Movement.GroundDashShort(delta)
		elif !Player.is_on_floor() and !Movement.hasDashedInAir:
			Movement.AirDashShort(delta)
	
	# Release = is held.
	elif inputDashHeldTime >= inputDashHeldMax  and  inputDashHeld == true:
		print("Dash Held:  ", inputDashHeldTime)
		inputDashHeldTime = 0
		inputDashHeld = false
		
		if Player.is_on_floor() and !Movement.dashCooldownActive:
			Movement.GroundDashLong(delta)
		elif !Player.is_on_floor() and !Movement.hasDashedInAir:
			Movement.AirDashLong(delta)


# Do melee attacks. Also throw when holding item.
func AttackInput():
	# Controller: Left Face Button / Left Bumper
	# Keyboard: LMB
	
	Combat.damage_tick += 1
	
	if Input.is_action_just_pressed("attack"):
		if Player.is_on_floor():
			Movement.InstaRot()
			Combat.Attack()
		
		else:
			Combat.GroundPound()


# Stuff like grapple hooks, interact, etc.
func AlternativeInput():
	# Controller: Top Face Button / Right Trigger
	# Keyboard: R
	pass

func LockOnInput():
	if Input.is_action_just_pressed("lock_on"):
		#if !Combat.weaponOut:
			#Combat.EnterLockMode()
		#else:
			#Combat.ExitLockMode()
		
		EnemyDetection.LockInput()
