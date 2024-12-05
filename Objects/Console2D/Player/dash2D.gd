extends Node

@onready var player: CharacterBody2D = $".."
var playerStates

@export var dashStrength := 700
@export var dashShortAirStrength : float = 1.8  # How fast moving while dashing.
@export var dashShortAirLength : float = 0.2  # How long is active
@export var dashLongAirStrength : float = 1.8  # How fast moving while dashing.
@export var dashLongAirLength : float = 0.4  # How long is active
@export var dashCooldown := 1
var hasDashedInAir := false
var dashCooldownActive := false
var inputDashHeld:bool = false
const inputDashHeldMax : int = 10 # How many frames max until youve considered the held state.
var inputDashHeldTime : int = 0 # How many frames currently held for.

func _ready() -> void:
	playerStates = player.states


func DashInput(delta):
	# Controller: Right Face Button / Left Trigger
	# Keyboard: L Shift
	
	if Input.is_action_just_pressed("dash"):
		inputDashHeld = true
	
	if Input.is_action_pressed("dash"):
		inputDashHeldTime += 1
	
	# Release = is tap.
	if Input.is_action_just_released("dash")  and  inputDashHeldTime < inputDashHeldMax  and  inputDashHeld == true:
		print("Dash Tap:  ", inputDashHeldTime)
		inputDashHeldTime = 0
		inputDashHeld = false
		
		if player.is_on_floor() and !dashCooldownActive:
			Dash (playerStates.DASHING_GROUNDED, true, dashShortAirStrength, dashShortAirLength, delta)
		elif !player.is_on_floor() and !hasDashedInAir:
			Dash (playerStates.DASHING_AIR_SHORT, true, dashShortAirStrength, dashShortAirLength, delta)
	
	# Release = is held.
	elif inputDashHeldTime >= inputDashHeldMax  and  inputDashHeld == true:
		print("Dash Held:  ", inputDashHeldTime)
		inputDashHeldTime = 0
		inputDashHeld = false
		
		if player.is_on_floor() and !dashCooldownActive:
			Dash (playerStates.DASHING_GROUNDED, true, dashLongAirStrength, dashLongAirLength, delta)
		elif !player.is_on_floor() and !hasDashedInAir:
			Dash (playerStates.DASHING_AIR_LONG, true, dashLongAirStrength, dashLongAirLength, delta)


func Dash(newState, inAir, multiplierStrength, lengthTime, delta):
	player.currentState = newState
	hasDashedInAir = inAir
	
	#player.velocity *= 0.25 # Half the current velocity, making it feel less stiff transition while changing momentum.
	
	# Dash velocity
	var inputX := Input.get_axis("move_left", "move_right")
	#if inputX == 0:
		#inputX = 1 * player.direction
	var inputY := Input.get_axis("move_down", "move_up")
	print("dash hh ", inputY)
	
	var strength = multiplierStrength * dashStrength# * delta
	#player.velocity += Vector2(inputX * strength,  inputY * strength)
	player.velocity = Vector2(inputX * strength,  inputY * strength)
	
	
	await get_tree().create_timer(lengthTime).timeout
	#velocity *= 0.05 # End velocity, without making it feel stiff.
	player.currentState = playerStates.FALLING
	
	dashCooldownActive = true
	await get_tree().create_timer(dashCooldown).timeout
	dashCooldownActive = false
