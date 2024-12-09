class_name PlayerCharacter
extends CharacterBody3D

signal coin_collected

var controlled := true

# Also referenced by other nodes calling to the player's child nodes.
@onready var Movement: Node = $Movement
@onready var Combat: Node = $Combat
@onready var Health: Node = $Health
@onready var StateMachine: Node = $StateMachine
@onready var sPortal: Node = $Portal
@onready var Inputs: Node = $Inputs
@onready var CameraRoot: Node3D = $CameraRoot
@onready var Camera: Node3D = %Camera3D
#@onready var lock_on_attachment_point: LockOnComponent = $LockOnComponent

#region COMPONENTS
@export_subgroup("Components")
##
@onready var character := $Character
@onready var mesh := $Character/Skeleton3D/CharacterMesh
@onready var animation := $Character/AnimationPlayer
@onready var paraglider := %Paraglider
@onready var audio: AudioStreamPlayer3D = $AudioPlayers/AudioPlayer  # Reminder! Sounds will cut eachother off, dont use just 1!
@onready var footsteps: AudioStreamPlayer3D = $AudioPlayers/Footsteps
@onready var coin_collecting_audioPlayer: AudioStreamPlayer3D = $AudioPlayers/CoinCollecting

## Timers
@onready var coin_collect_timer: Timer = $Timers/CoinCollectTimer

## Collision
@onready var below : Area3D = %BelowArea
@onready var forward_ray_cast: RayCast3D = $Raycasts/ForwardRayCast
#@onready var ledge_above_ray_cast: RayCast3D = $Raycasts/LedgeAboveRayCast
@onready var lower_forward_ray_cast: RayCast3D = $Raycasts/LowerForwardRayCast
@onready var hitbox: Area3D = %Hitbox

## Preloads
#const coinRef := preload("res://objects/coin.tscn")
#const damagePulse := preload("res://particles/DamagePulse.tscn")
const coinSound = preload("res://Assets/Audio/SFX/coin.ogg")

## Interacting References
var currentGrindRail

# Gadgets
var hasParaglider : bool = false
#endregion

#region OTHER
@export_subgroup("Other")
var coins := 0
var coinCollectSequence : int = 0
var coinCollectSeqCooldown : bool = false
#endregion




# < =========================== >

# Custom inputs:

# Alt+Shift+F = Fold all functions.

# Alt+Shift+U = Unfolds all functions

#character.global_rotation_degrees = Vector3(
			#X,  # flip
			#Y,  # turn left/right
			#Z)  # barrel roll


# < =========================== >


##############  TICK BASED  ###########################

func _enter_tree():
	pass

func _ready() -> void:
	paraglider.visible = false
	
	$Raycasts/ForwardRayCast.add_exception(self)
	%LedgeAboveRayCast.add_exception(self)
	#below.add_exception(self)
	#hitbox.add_exception(self)
	
	#coin_collect_timer.timeout.connect(_on_coin_collect_timer_timeout)
	
	await get_tree().create_timer(0.1).timeout
	#coin_collected.emit(player, coins)


## Every tick
func _process(delta):
	#print("Input: ", Input.keycode)
	pass

# Every physics tick
func _physics_process(delta):
	if !controlled:
		footsteps.stream_paused = true
		return
	
	if is_on_wall() and Math.IsMoving(velocity):
		ControllerVibration(0.013, 0, 0.1)
	
	# Rot last frame (based on input not rotation)
	var rot = Vector2(Inputs.movementInput.z, Inputs.movementInput.x).angle()
	rot = rad_to_deg(rot)


##### COLLISION ###########################

# All these are collision-based code.
# Not called from any function but from the area thats colliding itself.

func _Hitbox_body_entered(body):
	if body == self:
		return
	
	# Climb pole
	if (StateMachine.currentState == StateMachine.states.JUMPING  or  StateMachine.currentState == StateMachine.states.FALLING)  and  body.get_parent().is_in_group("Pole"):
		StateMachine.currentState = StateMachine.states.CLIMB_POLE
		Movement.gravity = 0
		print("==")
	
	# Air dash bump
	elif StateMachine.currentState == StateMachine.states.DASHING_AIR_SHORT:
		StateMachine.currentState = StateMachine.states.FALLING
		velocity = Vector3.ZERO
		Movement.gravity = -12
		move_and_slide() # To refuse velocity being changed if running another function.
	
	else:
		print("== Nope")

func _Hitbox_body_exited(body):
	pass # Replace with function body.

func _BelowArea_body_entered(body):
	if body == self:
		return
	
	print("Below Area:  ", body.get_meta("type"))
	
	# Stomp
	if !is_on_floor()  and  velocity.y < 0  and  body.get_parent().has_method("Stomped"):
		body.get_parent().Stomped()
		StateMachine.currentState = StateMachine.states.FALLING
		Movement.gravity = -Movement.jump_strength * 2
	
	# Static Stomp (squash and stretch on landing on things without bounciness)
	if !is_on_floor()  and  velocity.y < 0  and  body.get_parent().has_method("StaticStomped"):
		body.get_parent().StaticStomped()
	
	#if !body.get_meta("type"):
		#return
	
	# Stand on pole
	if StateMachine.currentState == StateMachine.states.FALLING  and  body.get_meta("type") == "Pole":
		#currentState = states.FALLING
		Movement.gravity = 0
		print("Climb pole")
	
	# Grind rail
	if body.get_parent().has_method("EnterRail"):
		EnterGrindRail(body)

func _BelowArea_body_exited(body):
	pass # Replace with function body.



##### COSMETIC / JUICE ##########################

# Things that arent needed but adds a bit more "mmph" in the gameplay.

func PlaySound(audioToPlay:AudioStream, pitchScale:float, randomness:float):
	audio.stream = audioToPlay
	
	var rng = RandomNumberGenerator.new()
	var f = rng.randf_range(pitchScale - randomness, pitchScale + randomness)
	audio.pitch_scale = f
	
	audio.play()

func PlayCoinSound():
	# Plays a higher pitch in sequence of everytime you jump collect than just randomly.
	var pitch = 0.8 + (0.05 * coinCollectSequence)
	coin_collecting_audioPlayer.pitch_scale = pitch
	coin_collecting_audioPlayer.play()

func SpawnParticle(particle, time):
	var p = particle.instantiate()
	owner.add_child(p)
	p.position = $Particles/ParticleTrail.global_position
	p.emitting = true
	await get_tree().create_timer(time).timeout # After enough time to finish...
	p.queue_free() # Delete the existance of it

func ControllerVibration(weakMotors:float, strongMotors:float, durationSeconds:float):
	# In the xbox one controller they have 4 motors.
	# 2 at the bottom that are strong. 2 at the top that a weak.
	# Max is 1, min is 0.
	
	#if Input.get_joy_vibration_strength(0).x < weakMotors: # Stopping the lower value cancelling the bigger one.
		#Input.start_joy_vibration(0, weakMotors, 0, durationSeconds)
	#print("sagger: ", Input.get_joy_vibration_strength(0), "  =  ", weakMotors)
	
	#if Input.get_joy_vibration_strength(0).y < strongMotors:
		#Input.start_joy_vibration(0, 0, strongMotors, durationSeconds)
	
	Input.start_joy_vibration(0, weakMotors, strongMotors, durationSeconds)
	
	# First value is device.
	# Does not work on PS4 or PS5 connected by USB. Switch Pro doesnt work at all. 
	# Probably would need API for those.

func StopAllControllerVibrations():
	Input.stop_joy_vibration(0)
	# 0 is the current controller device. So new function would be needed for multiplayer.

func WalkVibrations():
	if Math.IsMoving(velocity) and !Movement.movementVibrationCooldown:
		Movement.movementVibrationCooldown = true
		ControllerVibration(0.18, 0, 0.13)
		await get_tree().create_timer(0.3).timeout
		Movement.movementVibrationCooldown = false

func SwitchCamera(newCam:Camera3D, duration:float):
	CameraRoot.SwitchCamera(newCam, duration)



##### INTERACTABLES ###########################

# Collecting coins
func collect_coin():
	coins += 1
	
	#health += 5
	#health = clamp(health, 0, healthMax)
	#print(health)
	
	## Sequence 1
	print("HH  ", coinCollectSeqCooldown)
	if coinCollectSeqCooldown:
		coinCollectSequence += 1
		coinCollectSequence = clamp(coinCollectSequence, 0, 8)
	else:
		coinCollectSequence = 0 # Resets
	
	## Cosmetic
	PlayCoinSound()
	ControllerVibration(0.25, 0, 0.15)
	#coin_collected.emit(player, coins)
	
	## Sequence 2
	coinCollectSeqCooldown = true
	coin_collect_timer.start( coin_collect_timer.wait_time )

func CollectCheese():
	# Start
	controlled = false
	velocity = Vector3.ZERO
	
	# Animation playing right now
	await get_tree().create_timer(5).timeout
	
	# End
	controlled = true
	GameManager.AddCheese(1)

func SitOnBench(loc : Vector3,  rot : float):
	StateMachine.currentState = StateMachine.states.SITTING_ON_BENCH
	Movement.disableRotation = true
	velocity = Vector3.ZERO
	position = loc
	character.global_rotation_degrees.y = rot + 180

func JumpOffBench():
	StateMachine.currentState = StateMachine.states.FALLING
	Movement.disableRotation = false
	
	# Resetting the value for the rotation function, to not spin around to where they were when attaching.
	Movement.rotation_direction = character.rotation.y
	
	# Launch off
	Movement.gravity = -9
	velocity = Math.ForwardVector(self) * 9

func EnterGrindRail(body):
	StateMachine.currentState = StateMachine.states.RAIL_GRINDING
	currentGrindRail = body.get_parent()
	currentGrindRail.EnterRail(self, character)
	#var railGrindNode = find_nearest_rail_follower()
	Movement.gravity = 0
	print("Grind")

func LeaveGrindRail():
	StateMachine.currentState = StateMachine.states.FALLING
	currentGrindRail.LeaveRail()
	currentGrindRail = null
	Movement.gravity = -10

func EnterSlingshot(loc : Vector3,  rot : float):
	StateMachine.currentState = StateMachine.states.IN_SLINGSHOT
	Movement.disableMovement = true
	Movement.disableRotation = true
	velocity = Vector3.ZERO
	position = loc
	character.global_rotation_degrees.y = rot

func LaunchFromSlingshot(strength: float, direction : Vector3):
	Movement.Launch_Direction(strength, 0, 20, false, false)
	await get_tree().create_timer(0.1).timeout # Stop it from colliding with the ground before leaving.
	StateMachine.currentState = StateMachine.states.SLINGSHOT_LAUNCHED



######### TIMERS #########################
func _on_coin_collect_timer_timeout() -> void:
	coinCollectSeqCooldown = false
