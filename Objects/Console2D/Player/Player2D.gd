extends CharacterBody2D


@onready var dash: Node = $Dash

#region Variables
enum states {
	GROUNDED, JUMPING, FALLING, FALL_SQUASHED,
	DASHING_GROUNDED, DASHING_AIR_SHORT, DASHING_AIR_LONG,
	WALL_SLIDE, LEDGE_GRAB,
	ATTACKING, GROUND_POUNDING,
	PARAGLIDING,
	RAIL_GRINDING, GRAPPLE_SWINGING, SHOOTING_HOOK,
	CLIMB_POLE, STAND_ON_POLE 
	}
@export var currentState : states = states.FALLING
var isDefaultState := true

const speed = 200.0
const jumpStrength = -320.0
const gravityScale = 1.3   # 1 = default

var dead = false
var jumpBufferActive : bool = false
var coyotteTimeActive : bool = false
var grounded = false
var lastCheckpointLoc : Vector2
var cheeseLocations : Array[Vector2]
var controlled:bool = false
var camera:Camera2D

@onready var sprite = $AnimatedSprite2D
@onready var collider = $CollisionShape2D
@onready var audio_jump: AudioStreamPlayer2D = $AudioPlayers/AudioJump
@onready var audio_hurt: AudioStreamPlayer2D = $AudioPlayers/AudioHurt
@onready var audio_death: AudioStreamPlayer2D = $AudioPlayers/AudioDeath

const cameraRef = preload("res://Objects/Console2D/Player/Camera2D.tscn")
#endregion

func _ready():
	UpdateCheckpoint(position)
	#SpawnCamera()

func _physics_process(delta: float) -> void:
	if !controlled:
		return
	
	Gravity(delta)
	JumpInput()
	Movement(delta)
	dash.DashInput(delta)
	
	if grounded:
		if !is_on_floor():
			## On Launch action
			grounded = false
			if velocity.y > 0: # Not jumping, fell off a platform.
				coyotteTimeActive = true
				await get_tree().create_timer(0.15).timeout
				coyotteTimeActive = false
	else:
		if is_on_floor():
			## On Land action
			grounded = true
			if jumpBufferActive:
				Jump()
				jumpBufferActive = false
	
	# On the ground, idle or moving
	if currentState == states.GROUNDED:
		Movement(delta)
		Gravity(delta)
		#WalkVibrations()
	
	# Holding jump
	elif currentState == states.JUMPING:
		#_process_jumping(delta)
		pass
	
	# In the air and NOT jumping.
	elif currentState == states.FALLING:
		#_process_falling(delta)
		pass
	
	elif currentState == states.DASHING_GROUNDED:
		pass
	
	elif currentState == states.LEDGE_GRAB:
		#HoldingLedge(delta)
		pass
	
	elif currentState == states.WALL_SLIDE:
		#WallSlide()
		pass
	
	elif currentState == states.GRAPPLE_SWINGING:
		#GrappleSwing()
		pass
	
	elif currentState == states.SHOOTING_HOOK:
		pass
	
	elif currentState == states.ATTACKING:
		pass
	
	elif currentState == states.GROUND_POUNDING:
		#velocity = Vector3.ZERO
		#gravity += groundPound_OverTimeStrength
		Gravity(delta)
	
	elif currentState == states.FALL_SQUASHED:
		Movement(delta)
	
	move_and_slide()

func Movement(delta):
	if dead:
		return
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
	
	
	
	if direction == 0:
		pass
		## Play the idle animation
	elif direction == -1:
		## Play run animation
		sprite.flip_v = true
	elif direction == 1:
		## Play run animation
		sprite.flip_v = false

func JumpInput():
	if Input.is_action_just_pressed("jump"):
		if is_on_floor() or coyotteTimeActive:
			Jump()
		
		else:
			# Jump buffer
			jumpBufferActive = true
			await get_tree().create_timer(0.1).timeout
			jumpBufferActive = false

func Jump():
	velocity.y = jumpStrength
	audio_jump.play()

func Gravity(delta):
	if not is_on_floor():
		velocity += (get_gravity() * gravityScale) * delta
	#else:
		#currentState = states.GROUNDED

func Eat(CheeseLoc:Vector2):
	cheeseLocations.append(CheeseLoc) # Save locations to respawn on death

func Death():
	dead = true
	audio_death.play()
	Engine.time_scale = 0.5
	await get_tree().create_timer(0.5).timeout
	Engine.time_scale = 1
	
	#get_tree().reload_current_scene()
	position = lastCheckpointLoc
	
	var food = load("res://Scenes/Food.tscn")
	for i in cheeseLocations:
		var spawned = food.instantiate()
		get_parent().add_child(spawned)
		spawned.position = i
	cheeseLocations.clear()
	
	dead = false

func UpdateCheckpoint(newVector:Vector2):
	lastCheckpointLoc = newVector

func _on_hurtbox_body_entered(body: Node2D) -> void:
	Death()
	velocity = Vector2.UP * 300

func SpawnCamera():
	camera = cameraRef.instantiate()
	owner.add_child(camera)
	camera.Activate(self)
