class_name PlayerMovement
extends "player_shared.gd"


#region MOVEMENT
@export_subgroup("Movement")
@export var movement_speed := 500  # The speed which the player moves at.
var movement_velocity: Vector3
var lastFrameVel : Vector3
var lastGravity : float
var disableMovement:bool = false
var movementVibrationCooldown:bool = false

var warpSpeed:float = 0.8
var desiredWarpPos:Vector3
var desiredWarpRot:float

# Force
const toFullForceSpeed: float = 0.01  # How much it goes up0 every tick while holding input.
const minForce: float = 0.2 # It never goes below this number to stop from standing still for a short moment.
var force: float = minForce # The 0-1 value speed is multiplied to get a gradual to full speed result.

# Dash
enum dashStyle {CLOUD_TRAIL, GHOST}
@export var currentDashStyle : dashStyle = dashStyle.CLOUD_TRAIL
@export var dashStrength := 1.5
@export var dashShortAirStrength : float = 1.8  # How fast moving while dashing.
@export var dashShortAirLength : float = 0.2  # How long is active
@export var dashLongAirStrength : float = 1.8  # How fast moving while dashing.
@export var dashLongAirLength : float = 0.4  # How long is active
@export var dashCooldown := 1
var hasDashedInAir := false
var dashCooldownActive := false

# Other
var ledgeGrabCooldown:bool = false
#endregion

#region ROTATION
@export_subgroup("Rotation")
@export var rotationSpeed : float = 10  # How fast it takes to rotate to desired rotation.
@export var rotationSpeedAir : float = 7
var rotation_direction: float
var degreesLastFrame: float
var disableRotation:bool = false
#endregion

#region JUMPING / FALLING
@export_subgroup("Jumping / Falling")
@export var jump_strength : float = 11  # How strong the jumps are.
var jumpSequence : int = 0  # How many times youve jumped in a row.
var jumpSequenceCooldown : bool = false

# Multi-jumping
const maxJumps: int = 1 # How many jumps youre able to do. (1 = single jump, 2 = +1 double jump.)
var jumpCount: int = 0  # How many jumps youve done.

# Walk off a ledge still leaves an opening to jump as if you were on land.
const coyoteTime: float = 0.1
var coyoteActive: bool = false

# Press the jump input few pixels before landing, press to jump when land.
const jumpBuffer: float = 0.1
var jumpBufferActive: float = false

# Gravity
var gravity:float
var dropVal:float = 30 # The amount the player will keep dropping down.
var gravityOn: bool = true

# Grounded
var grounded := true
var previously_floored := false

# Wall Jump
var hasWallJumped : bool = false

var canLedgeGrab : bool = true

@onready var jumping_max_time_timer: Timer = $JumpingMaxTime

#endregion

#region COSMETIC / JUICE
@export_subgroup("Cosmetic / Juice")
@onready var SkeletalMesh: Skeleton3D = $"../Character/Skeleton3D"
@export var jumpStretchSize: Vector3 = Vector3(.15, .45, .15)
@export var jumpStretchSpeed: float = 0.5
@export var landSquashSize: Vector3 = Vector3(.45, .15, .25)
@export var landSquashSpeed: float = 0.8
const defaultSize: Vector3 = Vector3(0.3, 0.3, 0.3)
var jumpLandTween

#const LandParticles := preload("res://particles/ring_dust_particle.tscn")
#const GroundPoundParticles := preload("res://particles/ring_dust_particle_groundpound.tscn")
#const AirJumpParticles := preload("res://particles/ring_dust_particle_airjump.tscn")


#endregion

#region COMPONENTS
@onready var particle_trail := $"../Particles/ParticleTrail"
@onready var dash_particle_trail := $"../Particles/DashParticleTrail"

const dashGhost := preload("res://Objects/CharacterDashGhost.tscn")
const jumpSound = preload("res://Assets/Audio/SFX/jump.ogg")
#endregion


func _ready() -> void:
	#var tween = get_tree().create_tween().set_parallel(true)  # Continues without finishing
	#particle_trail.emitting = false
	#dash_particle_trail.emitting = false
	pass

func _physics_process(delta: float) -> void:
	Player.move_and_slide()
	
	if Health.dead:
		return
	
	if !Combat.weaponOut:
		Rotation(delta)
		Lean(delta)
	else:
		Rotation_LockedOn(delta)
		Lean_LockedOn(delta)
	
	previously_floored = Player.is_on_floor()
	lastFrameVel = Player.velocity
	lastGravity = gravity
	await get_tree().create_timer(0.5).timeout
	degreesLastFrame = Player.rotation.y
	HandleEffects(delta)

func _process(delta: float) -> void:
	HandleEffects(delta)

# Movement
func Move(delta):
	if disableMovement  or  !Combat.damage_tick >= Combat.INVULNERABILITY_TICK_DURATION:
		return
	
	if !Player.is_on_floor() and Player.is_on_wall():
		Player.velocity = Player.velocity.lerp(Vector3.ZERO, delta)
		return # End function to stop slide/float around while wall sliding.
	
	if Inputs.movementInput.length() != 0:
			force = clamp(force + toFullForceSpeed,  minForce, 1)
	else:
			force = clamp(force - toFullForceSpeed,  minForce, 1)
	
	var speed = 10 if Player.is_on_floor() else 4
	if StateMachine.currentState == StateMachine.states.FALL_SQUASHED:
		speed *= 0.1
	if Combat.weaponOut:
		speed *= 0.5
	#if StateMachine.currentState == StateMachine.states.BLOCKING:
		#speed *= 0.5
	Player.velocity = Player.velocity.lerp((movement_velocity * force), delta * speed)
	
	#print("force:", force)

# Rotation
func Rotation(delta):
	if disableRotation:
		return
	
	 # Only sets a new value while moving.
	if Vector2(Player.velocity.z, Player.velocity.x).length() > 0:
		rotation_direction = Vector2(Player.velocity.z, Player.velocity.x).angle()
		#print("Dir: ", rotation_direction)
	
	if Player.is_on_floor():
		Player.rotation.y = lerp_angle(Player.rotation.y,  rotation_direction,  delta * rotationSpeed)
	else:
		Player.rotation.y = lerp_angle(Player.rotation.y,  rotation_direction,  delta * rotationSpeedAir)
	
	# Makes sure values are between 0 and 360. If goes over 360, will go up from 0. Same other way around.
	Player.rotation_degrees.y = wrapf(Player.rotation_degrees.y, 0, 360)

func Rotation_LockedOn(delta):
	var target = Combat.targetedEnemy
	var pos2d:Vector2 = Vector2(Player.global_position.x, Player.global_position.z)
	var playerPos2d:Vector2 = Vector2(target.global_position.x, target.global_position.z)
	var direction = -(pos2d - playerPos2d)
	Player.rotation.y = lerp_angle(Player.rotation.y,  atan2(direction.x, direction.y), delta * 5)
	Player.rotation.x = 0
	Player.rotation.z = 0

# Instantly rotate to desired rotation, without lerp.
func InstaRot():
	if Vector2(Player.velocity.z, Player.velocity.x).length() > 0:
		Player.rotation.y = Vector2(Player.velocity.z, Player.velocity.x).angle()


##########  GRAVITY, LAUNCHING and LANDING  #########################

# Handle gravity
func Gravity(delta):
	if !gravityOn:
		gravity = 0
		return  # Ends function
	
	# Only have gravity forces if in air.
	# Prevents walking off ledge and being mega launched downwards.
	if !Player.is_on_floor():
		gravity += dropVal * delta
		gravity = clamp(gravity, -99900, 100)
	
	# Land/no longer grounded functions
	if !grounded and gravity > 0 and Player.is_on_floor():
		Landed()
	elif grounded and !Player.is_on_floor():
		grounded = false
		coyoteActive = true
		await get_tree().create_timer(coyoteTime).timeout
		coyoteActive = false
	
	Player.velocity.y = -gravity
	#print("Gravity: ", gravity)

# Landed
func Landed():
	print("_JUMP LANDED  ============")
	
	## Ground Pound
	if StateMachine.currentState == StateMachine.states.GROUND_POUNDING:
		Combat.is_attacking = false
		
		# Bounces up, but stronger if from a larger height.
		gravity = Combat.groundPound_BounceStrength - (lastGravity * 0.15) 
		print("LastVal ", lastGravity)
		
		StateMachine.currentState = StateMachine.states.FALLING
		
		if jumpBufferActive:
			gravity = -jump_strength * 2.5
			jumpBufferActive = false
			print("Jump (buffered)")
		
		#SpawnParticle(GroundPoundParticles, 4)
		
		#var pulse = damagePulse.instantiate()
		#owner.add_child(pulse)
		#pulse.position = particles_trail.global_position
		#pulse.owningPlayer = self
		
		return
	
	## Slingshot
	elif StateMachine.currentState == StateMachine.states.SLINGSHOT_LAUNCHED:
		StateMachine.currentState = StateMachine.states.GROUNDED
		Player.velocity = Vector3.ZERO
		disableRotation = false
		disableMovement = false
		print("Per:YE")
	
	# Specifically not anything above
	else:
		#SpawnParticle(LandParticles, 4)
		pass
	
	
	print("LANDED IN state:  ", StateMachine.currentState)
	
	gravity = 0
	grounded = true
	hasDashedInAir = false
	gravityOn = true
	dashCooldownActive = false
	Inputs.jumpButtonHeldValue = 0
	jumpCount = 0
	hasWallJumped = false
	#paraglider.visible = false
	disableRotation = false
	
	
	if !jumping_max_time_timer.is_stopped():
		jumping_max_time_timer.stop()
	
	if is_instance_valid(Camera):
		Camera.PlayerLanded()
	
	# Heavy land stagger
	#if gravity > 500:
		#Player.StopAllControllerVibrations()
		#Player.ControllerVibration(0, 0.8, 0.4)
		#$"../Character/BasicRat_ForPrototype".scale = Vector3( 1.2, 0.8, 1.2 )
		#StateMachine.currentState = StateMachine.states.FALL_SQUASHED
		#await get_tree().create_timer(3).timeout
		#StateMachine.currentState = StateMachine.states.GROUNDED
	#else:
		#Player.StopAllControllerVibrations()
		#Player.ControllerVibration(0.35, 0, 0.3)
		#LandTween()
		#StateMachine.currentState = StateMachine.states.GROUNDED
	$"../Character/BasicRat_ForPrototype".scale = Vector3(0.4, 0.2, 0.4)
	Player.StopAllControllerVibrations()
	Player.ControllerVibration(0.35, 0, 0.3)
	LandTween()
	StateMachine.currentState = StateMachine.states.GROUNDED
	
	print("Landed")
	
	
	jumpSequenceCooldown = true
	await get_tree().create_timer(0.3).timeout
	jumpSequenceCooldown = false
	
	if jumpBufferActive:
		Jump()
		jumpBufferActive = false
		print("Jump (buffered)")

# Done at the beginning of jumping.
func JumpStart():
	print("_JUMP STARTED")
	jumpCount += 1
	StateMachine.currentState = StateMachine.states.JUMPING
	
	if !jumping_max_time_timer.is_stopped():
		jumping_max_time_timer.stop()
		print("_JUMP TIMER FORCED STOPPED")
	jumping_max_time_timer.start()
	
	if is_instance_valid(Camera):
		Camera.PlayerJumped()
	
	Player.ControllerVibration(0.2, 0, 0.2)
	
	## Sequence
	if jumpSequenceCooldown:
		if jumpSequence == 3:
			jumpSequence = 1 # Resets
		else:
			jumpSequence += 1
			jumpSequence = clamp(jumpSequence, 0, 3)
	else:
		jumpSequence = 1 # Resets
	
	# Cosmetics
	$"../Character/BasicRat_ForPrototype".scale = Vector3(0.2, 0.4, 0.2)
	JumpTween()
	animation.play("Jump")
	#PlaySound(jumpSound, 1.12, 0.5)
	PlayJumpSound()
	
	# Make unable to grab ledges the second you jump. That way you dont get stuck when jumping off ledge.
	canLedgeGrab = false
	await get_tree().create_timer(0.01).timeout
	canLedgeGrab = true

# Jumping
func Jump():
	#var seq : float = (jumpSequence * 1) # The amount to remove, making each jump sequence able to be jump held longer.
	gravity = -jump_strength# - seq

func JumpCombat():
	StateMachine.currentState = StateMachine.states.JUMPING
	
	if is_instance_valid(Camera):
		Camera.PlayerJumped()
	
	Player.ControllerVibration(0.2, 0, 0.2)
	
	# Cosmetics
	$"../Character/BasicRat_ForPrototype".scale = Vector3(0.2, 0.4, 0.2)
	JumpTween()
	animation.play("Jump")
	#PlaySound(jumpSound, 1.12, 0.5)
	PlayJumpSound()
	
	gravity = -jump_strength * 6

## Probably delete, this character doesnt double jump at the moment.
# Double (tripple, quadrupel etc.) Jump
func MultiJump():
	Player.velocity = Vector3.ZERO  # Reset velocity for more control on the double jump.
	gravity = -jump_strength
	SkeletalMesh.scale = Vector3(0.5, 1.5, 0.5)
	jumpCount += 1
	print("Double Jump")
	
	#SpawnParticle(LandParticles, 4)
	animation.play("Jump", 0.5)
	#await animation.animation_finished
	Player.PlaySound(jumpSound, 1.12, 0.5)

# Jump out of dash.
func LongJump():
	gravity = -jump_strength
	var strength = 0.5 * dashStrength  # Continue most strength
	Player.velocity += Vector3(movement_velocity.x * strength,  0,  movement_velocity.z * strength)
	dashCooldownActive = false # So if you jump you cancel the cooldown time.
	print("long jump")

func Launch_Vec3(direction:Vector3):
	if direction.y > 0:
		StateMachine.currentState = StateMachine.states.FALLING
	
	Player.velocity = direction
	gravity = -direction.y

func Launch_Direction(forwardVec:float, rightVec:float, upVec:float, added:bool, currentStateFalling:bool):
	if upVec > 0 and currentStateFalling:
		StateMachine.currentState = StateMachine.states.FALLING
	
	if !added:
		Player.velocity = Vector3.ZERO
	
	Player.velocity += forwardVec * Math.ForwardVector(Player)
	Player.velocity += rightVec * Math.RightVector(Player)
	Player.velocity.y += upVec
	gravity = -upVec

func PlayJumpSound():
	# Plays a higher pitch in sequence of everytime you jump rather than just randomly.
	
	AudioPlayer.stream = jumpSound
	
	## Pitch
	var pitch = 1.12 + (0.2 * Movement.jumpSequence)
	AudioPlayer.pitch_scale = pitch
	
	AudioPlayer.play()

# Short dash on the ground, short slide.
func GroundDashShort(delta):
	StateMachine.currentState = StateMachine.states.DASHING_GROUNDED
	
	if  movement_velocity != Vector3.ZERO:
		Player.velocity += Vector3(movement_velocity.x * dashStrength,  0,  movement_velocity.z * dashStrength)
	else:
		var dir = mesh.get_global_transform().basis.z
		var strength = dashStrength * movement_speed * delta
		Player.velocity += Vector3(dir.x * strength,  0,  dir.z * strength)
	
	var dashLength = 0.2
	
	# Have a trail of clouds leading behind.
	if currentDashStyle == dashStyle.CLOUD_TRAIL:
		dash_particle_trail.emitting = true
		await get_tree().create_timer(dashLength).timeout
		dash_particle_trail.emitting = false
	
	# Have 3 ghosts showing your past positions
	elif currentDashStyle == dashStyle.GHOST:
		var ghost = dashGhost.instantiate()
		owner.add_child(ghost)
		ghost.position = Player.global_position
		ghost.rotation = mesh.global_rotation
		
		await get_tree().create_timer(dashLength / 3).timeout
		
		var ghost2 = dashGhost.instantiate()
		owner.add_child(ghost2)
		ghost2.position = Player.global_position
		ghost2.rotation = mesh.global_rotation
		
		await get_tree().create_timer(dashLength / 3).timeout
		
		var ghost3 = dashGhost.instantiate()
		owner.add_child(ghost3)
		ghost3.position = Player.global_position
		ghost3.rotation = mesh.global_rotation
		
		await get_tree().create_timer(dashLength / 3).timeout
	
	
	StateMachine.SetToDefaultState()
	
	dashCooldownActive = true
	await get_tree().create_timer(dashCooldown).timeout
	dashCooldownActive = false

# Long dash on the ground, lengthy leap.
func GroundDashLong(delta):
	StateMachine.currentState = StateMachine.states.DASHING_GROUNDED
	
	if  movement_velocity != Vector3.ZERO:
		Player.velocity += Vector3(movement_velocity.x * dashStrength,  0,  movement_velocity.z * dashStrength)
	else:
		var dir = mesh.get_global_transform().basis.z
		var strength = dashStrength * movement_speed * delta
		Player.velocity += Vector3(dir.x * strength,  0,  dir.z * strength)
	
	var dashLength = 0.2
	
	# Have a trail of clouds leading behind.
	if currentDashStyle == dashStyle.CLOUD_TRAIL:
		dash_particle_trail.emitting = true
		await get_tree().create_timer(dashLength).timeout
		dash_particle_trail.emitting = false
	
	# Have 3 ghosts showing your past positions
	elif currentDashStyle == dashStyle.GHOST:
		var ghost = dashGhost.instantiate()
		owner.add_child(ghost)
		ghost.position = Player.global_position
		ghost.rotation = mesh.global_rotation
		
		await get_tree().create_timer(dashLength / 3).timeout
		
		var ghost2 = dashGhost.instantiate()
		owner.add_child(ghost2)
		ghost2.position = Player.global_position
		ghost2.rotation = mesh.global_rotation
		
		await get_tree().create_timer(dashLength / 3).timeout
		
		var ghost3 = dashGhost.instantiate()
		owner.add_child(ghost3)
		ghost3.position = Player.global_position
		ghost3.rotation = mesh.global_rotation
		
		await get_tree().create_timer(dashLength / 3).timeout
	
	
	StateMachine.SetToDefaultState()
	
	dashCooldownActive = true
	await get_tree().create_timer(dashCooldown).timeout
	dashCooldownActive = false

# Dash in the air to reach further distances.
# Tap dash input for a short kick dash (bumps into walls and launches up)
func AirDashShort(delta):
	StateMachine.currentState = StateMachine.states.DASHING_AIR_SHORT
	hasDashedInAir = true
	
	Player.velocity *= 0.25 # Half the current velocity, making it feel less stiff transition while changing momentum.
	
	# Dash velocity
	if  movement_velocity != Vector3.ZERO:
		Player.velocity += Vector3(movement_velocity.x * dashShortAirStrength,  0,  movement_velocity.z * dashShortAirStrength) 
	else:
		var dir = mesh.get_global_transform().basis.z
		var strength = dashShortAirStrength * movement_speed * delta
		Player.velocity += Vector3(dir.x * strength,  0,  dir.z * strength)
	
	dash_particle_trail.emitting = true
	await get_tree().create_timer(dashShortAirLength).timeout
	#velocity *= 0.05 # End velocity, without making it feel stiff.
	StateMachine.SetToDefaultState()
	dash_particle_trail.emitting = false
	
	dashCooldownActive = true
	await get_tree().create_timer(dashCooldown).timeout
	dashCooldownActive = false

# Dash in the air to reach further distances.
# Hold dash input for a lengthy leaping dash (better for distances but does nothing when bumps into things)
func AirDashLong(delta):
	StateMachine.currentState = StateMachine.states.DASHING_AIR_LONG
	hasDashedInAir = true
	
	Player.velocity *= 0.25 # Half the current velocity, making it feel less stiff transition while changing momentum.
	
	# Dash velocity
	if  movement_velocity != Vector3.ZERO:
		Player.velocity += Vector3(movement_velocity.x * dashLongAirStrength,  0,  movement_velocity.z * dashLongAirStrength) 
	else:
		var dir = mesh.get_global_transform().basis.z
		var strength = dashLongAirStrength * movement_speed * delta
		Player.velocity += Vector3(dir.x * strength,  0,  dir.z * strength)
	
	dash_particle_trail.emitting = true
	await get_tree().create_timer(dashLongAirLength).timeout
	#velocity *= 0.05 # End velocity, without making it feel stiff.
	StateMachine.SetToDefaultState()
	dash_particle_trail.emitting = false
	
	dashCooldownActive = true
	await get_tree().create_timer(dashCooldown).timeout
	dashCooldownActive = false

func CombatDash(delta):
	StateMachine.currentState = StateMachine.states.DASHING_GROUNDED
	
	var forwardback = mesh.get_global_transform().basis.z * -Inputs.rawMovementInput.z
	var leftright = mesh.get_global_transform().basis.x * -Inputs.rawMovementInput.x
	var combined = forwardback + leftright
	var strength = (dashStrength * 1.5) * movement_speed * delta
	Player.velocity += Vector3(combined.x * strength,  0,  combined.z * strength)
	
	# Have a trail of clouds leading behind.
	var dashLength = 0.05
	dash_particle_trail.emitting = true
	await get_tree().create_timer(dashLength).timeout
	dash_particle_trail.emitting = false
	
	StateMachine.SetToDefaultState()
	
	dashCooldownActive = true
	await get_tree().create_timer(dashCooldown * 0.25).timeout
	dashCooldownActive = false

func Warp(delta):
	Player.position = lerp(Player.position, desiredWarpPos, warpSpeed * delta)
	#rotation.y = lerp_angle(rotation.y, desiredWarpRot, warpSpeed * delta)
	#rotation.y = move_toward(rotation.y, desiredWarpRot, warpSpeed * delta)
	Player.rotation.x = 0
	Player.rotation.z = 0


##### WALLS ###########################

func DetectWall():
	if !canLedgeGrab or ledgeGrabCooldown:
		return
	
	#DrawLine3D.DrawRay( %ForwardRayCast, 0.5 )
	#DrawLine3D.DrawRay( %LedgeAboveRayCast, 0.5 )
	#DrawLine3D.DrawRay( %LedgeAboveRayCast, 0.5 )
	
	# Attach to Ledge
	if %ForwardRayCast.is_colliding() and !%LedgeAboveRayCast.is_colliding():
		LedgeGrab()
		print("Wall: Ledge")
		return
	
	# Vault
	#if lower_forward_ray_cast.is_colliding() and !forward_ray_cast.is_colliding():
		#gravity = -10
		#print("Wall: Vault")
		#return
	
	# Wall Slide
	if %ForwardRayCast.is_colliding() and %LedgeAboveRayCast.is_colliding():
		EnterWallSlide()
		print("Wall: Wall Slide")
		return
	
	# Wall Run

func LedgeGrab():
	StateMachine.currentState = StateMachine.states.LEDGE_GRAB
	disableRotation = true
	$"../CollisionShape3D".disabled = true # Disable player's collision to not collide with the wall.
	
	const offsetBack = 0.2
	const offsetDown = 0.65
	var normal = Player.forward_ray_cast.get_collision_normal()
	var newPos = Player.forward_ray_cast.get_collision_point()
	newPos -= Math.BackwardVector(Player) * offsetBack # Moves back out of the wall
	
	Player.look_at( Player.global_position + normal )
	warpSpeed = 6
	#desiredWarpRot = position.direction_to(normal).angle()
	desiredWarpPos = newPos
	
	# Height
	var rayDown = %LedgeAboveRayCast_Down
	#rayDown.position =  # Sets the forwards value of the arrow to actually the ledge incase its thin.
	var rayDown_collisionPoint = rayDown.get_collision_point().y
	desiredWarpPos.y = rayDown_collisionPoint - offsetDown 
	
	#ledge_above_ray_cast.enabled = true

func HoldingLedge(delta):
	Player.velocity = Vector3.ZERO
	animation.play("EdgeGrab", 0.5)
	Movement.Warp(delta)

func DetatchLedge():
	disableRotation = false
	$"../CollisionShape3D".disabled = false
	ledgeGrabCooldown = true
	
	Movement.JumpStart()
	Movement.Jump()
	
	await get_tree().create_timer(0.8).timeout
	ledgeGrabCooldown = false

func EnterWallSlide():
	if hasWallJumped:
		return
	
	if Player.is_on_wall()  and  !Player.is_on_floor():#  and  ledge_above_ray_cast.is_colliding():
		if gravity > 0:
			gravity = 0
		
		Player.velocity = Vector3.ZERO
		StateMachine.currentState = StateMachine.states.WALL_SLIDE
		
		## Rotation
		disableRotation = true
		Player.look_at( Player.global_position + Player.get_wall_normal() )
		Player.rotation.x = 0
		Player.rotation.z = 0

func WallSlide():
	Player.velocity = Vector3(0, -0.2, 0)

func WallJump():
	var rotatedAxis = Inputs.rawMovementInput.rotated(Vector3.FORWARD, Camera.rotation.y).normalized()
	# Z = UP / DOWN
	# Y = LEFT / RIGHT
	
	# Movement input on all 4 axis's rotated based on camer rotation.
	var rot = Vector2(rotatedAxis.z, rotatedAxis.y).angle()
	#rot = rad_to_deg(rot) # Turns low values into -180 to 180
	
	var cameraForwardVector = -mesh.get_global_transform().basis.z
	var cameraRightVector = Camera.get_global_transform().basis.x
	
	#var camRot = camera.global_rotation_degrees
	
	
	var difference = Player.global_rotation.angle_to(Camera.global_rotation)
	#difference += rot
	
	
	var y = Player.global_rotation_degrees.y
	var y1 = y - 120 # Value of what if it were lass.
	var y2 = y + 120 # Value of what if it was more.
	y1 = wrapf(y1, -180, 180) # If it goes above or below these values, will transfer the rest through the other side.
	y2 = wrapf(y2, -180, 180)
	
	#print("Jay  ", rotatedAxis)
	print("Jay     Input rot: (", rot, ")  -  Global rot: (", y, ")  -  Added/Minus: (", y1, ") (", y2, ")    -  Jump away from wall: ", (rot < y1  and  rot > y2))
	print("Jay: 3", difference)
	
	# Jump away from the wall.
	if rot < y1  and  rot > y2:
		gravity = -10  # Launch up
		Player.velocity = Player.get_wall_normal() * 20  # Launch off wall
		Player.velocity += Inputs.movementInput * 5 # Give an amount of directional control from the jump off
		disableRotation = false
	
	# Launch while still hugging the wall
	else:
		Player.velocity = Math.RightVector(Player) * (Inputs.rawMovementInput.x * 15)
		#gravity = -2 + (rawMovementInput.z * 13) # Always launches up an amount
		gravity = -2 + (Inputs.movementInput.x * -10) # Always launches up an amount
		hasWallJumped = true
		# Should change from raw input, so camera can be angled and you can just point towards the wall.
		# Thats the only difference CornKidz has aswell to this system.
		
		# Maybe use this but change the Vector3.UP to something else?
		#movementInput = rawMovementInput.rotated(Vector3.UP, spring_arm.rotation.y).normalized()
	
	jumpCount += 1
	StateMachine.currentState = StateMachine.states.JUMPING
	SkeletalMesh.scale = Vector3(0.5, 1.5, 0.5) # Stretch
	JumpTween()
	animation.play("Jump")
	PlayJumpSound()

func WallRun():
	pass


##### COSMETIC / JUICE ##########################

func HandleEffects(delta):
	#return
	particle_trail.emitting = false
	footsteps.stream_paused = true
	
	if StateMachine.currentState == StateMachine.states.GROUNDED:
		if Math.IsMoving(Player.velocity):
			animation.play("Run", 0.5)
			particle_trail.emitting = true
			footsteps.stream_paused = false
		else:
			animation.play("Idle", 0.5)
	
	## Heavy land squash
	#if !StateMachine.currentState == StateMachine.states.FALL_SQUASHED:
		#$"../Character/BasicRat_ForPrototype".scale = $"../Character/BasicRat_ForPrototype".scale.lerp(Vector3(0.3, 0.3, 0.3), delta * 5)

func Lean(delta:float):
	#return
	
	var X : float = 0
	var Z : float = 0
	
	if Math.IsMoving(Player.velocity)  and  StateMachine.currentState == StateMachine.states.GROUNDED:
		Z = (Player.rotation.y - degreesLastFrame) * -500
		#Z = abs(Player.rotation.y - degreesLastFrame) * 5
		X = Player.velocity.length() * 3
		
		#print("Lean: ", Player.rotation.y - degreesLastFrame, "  ", Z, "  ",Player.rotation.y)
		X = clamp(X, 0, 30)
		Z = clamp(Z, -20, 20)
	
	# Left/Right (based on turning around)
	mesh.rotation_degrees.z = lerp(mesh.rotation_degrees.z,  Z,  delta * 4)
	
	# Forward (based on speed)
	mesh.rotation_degrees.x = lerp(mesh.rotation_degrees.x,  X,  delta * 6)

func Lean_LockedOn(delta:float):
	var X : float = 0
	var Z : float = 0
	
	if Math.IsMoving(Player.velocity)  and  StateMachine.currentState == StateMachine.states.GROUNDED:
		Z = Inputs.rawMovementInput.x * 20
		X = Inputs.rawMovementInput.z * -20
	
	# Left/Right (based on turning around)
	mesh.rotation_degrees.z = lerp(mesh.rotation_degrees.z,  Z,  delta * 4)
	
	# Forward (based on speed)
	mesh.rotation_degrees.x = lerp(mesh.rotation_degrees.x,  X,  delta * 6)


func JumpTween():
	if jumpLandTween:
		jumpLandTween.kill()
	jumpLandTween = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	$"../Character/BasicRat_ForPrototype".scale = jumpStretchSize
	jumpLandTween.tween_property($"../Character/BasicRat_ForPrototype", "scale", defaultSize, jumpStretchSpeed)

func LandTween():
	if jumpLandTween:
		jumpLandTween.kill()
	jumpLandTween = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	$"../Character/BasicRat_ForPrototype".scale = landSquashSize
	jumpLandTween.tween_property($"../Character/BasicRat_ForPrototype", "scale", defaultSize, landSquashSpeed)


func _on_jumping_max_time_timeout() -> void:
	StateMachine.currentState = StateMachine.states.FALLING
	print("_JUMP TIMER ENDED")
