extends Node3D

#region VARIABLES
enum states {
	INSPECT, TRANSITIONING,
	YANK_OFF_BATTERY_LID,
	TAKE_OUT_BATTERY_1, TAKE_OUT_BATTERY_2,
	UNSCREW_1, UNSCREW_2, UNSCREW_3, UNSCREW_4, UNSCREW_5,
	TAKE_CASE_OFF, 
	SCRUBBING_FRONT, SCRUBBING_BACK, PICKING_PAINT, 
	TAKE_OFF_SCREEN, PLACE_IN_NEW_SCREEN,
	REPLACE_SPEAKER,
	CLEAN_CURCUIT_BOARD_1, CLEAN_CURCUIT_BOARD_2,
	SCREW_IN_1, SCREW_IN_2, SCREW_IN_3, SCREW_IN_4,
	PLACE_BATTERY_IN_1, PLACE_BATTERY_IN_2, PLACE_BATTERY_LID_IN,
	FINISHED
	}
@export var currentState : states = states.INSPECT

enum colors {
	GREEN, PURPLE, HOT_PINK, BLUE, PINK, RED, 
	RETRO, TRANSPARENT, WHITE, BLACK
	}
@export var currentColor : colors = colors.GREEN

var activated:bool = false
var player
@onready var gameboy: Node3D = %GameboyRoot
var currentCamera:Camera3D

## Standing
@onready var CAMERA_inspecting: Camera3D = $Camera3D_Inspecting
@onready var CAMERA_lid: Camera3D = $Camera3D_Lid
@onready var CAMERA_screw_1st: Camera3D = $Camera3D_Screw_1st
@onready var CAMERA_screw_2nd: Camera3D = $Camera3D_Screw_2nd
@onready var CAMERA_screw_battery: Camera3D = $Camera3D_Screw_InsideBattery

## Lid
var mashedAmount:int = 0

## Screws (General)
const screwMoveSpeed:float = 0.7
const screwRotSpeed:float = 0.1
const distToScrewOn:float = 2

## Screw 1
@onready var screw_1: MeshInstance3D = %Gameboy/Screw_1
@onready var screw_1_in: Marker3D = %Gameboy/Screw_1_In
@onready var screw_1_out: Marker3D = %Gameboy/Screw_1_Out
@onready var camera_3d_screw_1: Camera3D = $Camera3D_Screw_2

## Screw 2
@onready var screw_2: MeshInstance3D = %Gameboy/Screw_2
@onready var screw_2_in: Marker3D = %Gameboy/Screw_2_In
@onready var screw_2_out: Marker3D = %Gameboy/Screw_2_Out
@onready var camera_3d_screw_2: Camera3D = $Camera3D_Screw_2

## Screw 3
@onready var screw_3: MeshInstance3D = %Gameboy/Screw_3
@onready var screw_3_in: Marker3D = %Gameboy/Screw_3_In
@onready var screw_3_out: Marker3D = %Gameboy/Screw_3_Out
@onready var camera_3d_screw_3: Camera3D = $Camera3D_Screw_3

## Screw 4
@onready var screw_4: MeshInstance3D = %Gameboy/Screw_4
@onready var screw_4_in: Marker3D = %Gameboy/Screw_4_In
@onready var screw_4_out: Marker3D = %Gameboy/Screw_4_Out
@onready var camera_3d_screw_4: Camera3D = $Camera3D_Screw_4

var finished:bool = false
#endregion



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	currentCamera = $Camera3D_Inspecting

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !activated:
		return
	
	print("Console Repair State:  ", states.keys()[currentState])
	
	## PHASE 0
	if currentState == states.INSPECT:
		var input = Vector2.ZERO
		input.x = Input.get_axis("move_left", "move_right")
		input.y = Input.get_axis("move_up", "move_down")
		
		gameboy.rotation.y += input.x * 0.1
		gameboy.rotation_degrees.y = wrapf(gameboy.rotation_degrees.y, 0, 360)
		
		gameboy.rotation.x += input.y * 0.1
		gameboy.rotation_degrees.x = clampf(gameboy.rotation_degrees.x, -65, 65)
		
		if Input.is_action_just_pressed("attack"):
			if !finished:
				Transition(states.YANK_OFF_BATTERY_LID, CAMERA_lid, $Gameboy_Lid, 1)
			else:
				pass
				#Exit
	
	elif currentState == states.TRANSITIONING:
		pass
	
	
	## PHASE 1
	elif currentState == states.YANK_OFF_BATTERY_LID:
		var fin = false
		
		if Input.is_action_just_pressed("attack"):
			mashedAmount += 1
		
		if mashedAmount == 5:
			fin = true
		
		if fin:
			Transition(states.UNSCREW_1, CAMERA_screw_1st, $Gameboy_Screw_1, 1)
	
	
	## PHASE 2
	elif currentState == states.TAKE_OUT_BATTERY_1:
		pass
	
	elif currentState == states.TAKE_OUT_BATTERY_2:
		pass
	
	
	## PHASE 3
	elif currentState == states.UNSCREW_1:
		var fin = Screw(screw_1, screw_1_in, screw_1_out, true, delta)
		
		if fin:
			Transition(states.UNSCREW_2, CAMERA_screw_1st, $Gameboy_Screw_2, 1)
			screw_1.position = screw_1_out.position # Put it in position for next time its used.
	
	elif currentState == states.UNSCREW_2:
		var fin = Screw(screw_2, screw_2_in, screw_2_out, true, delta)
		
		if fin:
			# Transition to 3
			Transition(states.UNSCREW_3, CAMERA_screw_2nd, $Gameboy_Screw_1, 1)
			screw_2.position = screw_2_out.position # Put it in position for next time its used.
	
	elif currentState == states.UNSCREW_3:
		var fin = Screw(screw_3, screw_3_in, screw_3_out, true, delta)
		
		if fin:
			# Transition to 4
			Transition(states.UNSCREW_4, CAMERA_screw_2nd, $Gameboy_Screw_2, 1)
			screw_3.position = screw_3_out.position # Put it in position for next time its used.
	
	elif currentState == states.UNSCREW_4:
		var fin = Screw(screw_4, screw_4_in, screw_4_out, true, delta)
		
		if fin:
			# Transition to the next phase
			Transition(states.SCREW_IN_1, CAMERA_screw_1st, $Gameboy_Screw_1, 1)
			screw_4.position = screw_4_out.position # Put it in position for next time its used.
	
	
	## PHASE 4
	elif currentState == states.TAKE_CASE_OFF:
		pass
	
	
	## PHASE 5
	elif currentState == states.SCRUBBING_FRONT:
		pass
	
	elif currentState == states.SCRUBBING_BACK:
		pass
	
	
	## PHASE 6
	elif currentState == states.PICKING_PAINT:
		pass
	
	
	## PHASE 7
	elif currentState == states.TAKE_OFF_SCREEN:
		pass
	
	elif currentState == states.PLACE_IN_NEW_SCREEN:
		pass
	
	
	## PHASE 8
	elif currentState == states.REPLACE_SPEAKER:
		pass
	
	
	## PHASE 9
	elif currentState == states.CLEAN_CURCUIT_BOARD_1:
		pass
	
	elif currentState == states.CLEAN_CURCUIT_BOARD_2:
		pass
	
	
	## PHASE 10
	elif currentState == states.SCREW_IN_1:
		var fin = Screw(screw_1, screw_1_in, screw_1_out, false, delta)
		
		if fin:
			# Transition to 2
			Transition(states.SCREW_IN_2, CAMERA_screw_1st, $Gameboy_Screw_2, 1)
	
	elif currentState == states.SCREW_IN_2:
		var fin = Screw(screw_2, screw_2_in, screw_2_out, false, delta)
		
		if fin:
			# Transition to 3
			Transition(states.SCREW_IN_3, CAMERA_screw_2nd, $Gameboy_Screw_1, 1)
	
	elif currentState == states.SCREW_IN_3:
		var fin = Screw(screw_3, screw_3_in, screw_3_out, false, delta)
		
		if fin:
			# Transition to 4
			Transition(states.SCREW_IN_4, CAMERA_screw_2nd, $Gameboy_Screw_2, 1)
	
	elif currentState == states.SCREW_IN_4:
		var fin = Screw(screw_4, screw_4_in, screw_4_out, false, delta)
		
		if fin:
			# Transition to the next phase
			Transition(states.INSPECT, CAMERA_inspecting, $Gameboy_Inspecting, 1)
	
	
	## PHASE 11
	elif currentState == states.PLACE_BATTERY_IN_1:
		pass
	
	elif currentState == states.PLACE_BATTERY_IN_2:
		pass
	
	elif currentState == states.PLACE_BATTERY_LID_IN:
		pass

func Transition(newState:states, newCam:Camera3D, newMarker, transitionDuration:float):
	currentState = states.TRANSITIONING
	
	# Camera
	GlobalCamera.transitionCamera3D(currentCamera, newCam, transitionDuration)
	currentCamera = newCam # For next time this function runs.
	
	# Move the console
	TweenTransform(gameboy, newMarker, transitionDuration)
	
	await get_tree().create_timer(transitionDuration).timeout
	currentState = newState

func _on_area_3d_body_entered(body: Node3D) -> void:
	player = body
	var duration = 1
	body.SwitchCamera(CAMERA_inspecting, duration)
	body.controlled = false
	activated = true
	await get_tree().create_timer(duration).timeout
	currentState = states.INSPECT

func TweenTransform(from, to, duration:float = 1.0):
	var tween:Tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(from, "global_transform", to.global_transform, duration)

func Screw(screw, inVal, outVal, goalIsOut, delta):
	var input = Input.get_axis("move_up", "move_down")
	
	var speed
	var resitant:bool = false
	if screw.position.distance_to(inVal.position) < distToScrewOn:
		speed = screwMoveSpeed * 0.8 # Bit more resistance
		resitant = true
	else:
		speed = screwMoveSpeed * 10 # Screw hasnt even touched the device yet.
	
	if input > 0: # Down
		screw.position.z += speed * delta
		screw.rotation.z += screwRotSpeed
	elif input < 0: # Up
		screw.position.z -= speed * delta
		screw.rotation.z -= screwRotSpeed
	if input != 0  and resitant:
		Input.start_joy_vibration(0, 0.03, 0, 0.1)
	screw.position.z = clampf(screw.position.z, outVal.position.z, inVal.position.z)
	
	var finished := false
	if goalIsOut  and  screw.position.distance_to(inVal.position) > 5:
		finished = true
	elif !goalIsOut  and  screw.position.distance_to(inVal.position) < 0.1:
		screw.position = inVal.position
		finished = true
	
	return finished
