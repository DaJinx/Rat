extends Node3D

@onready var Keyboard = $Keyboard
@onready var PS4 = $PS4_Root/PS4
@onready var PS5 = $PS5
@onready var Unknown = $Unknown
var conActivating = false
var conReturning = false
var currentCon
var desiredCon
var firstTime = true


func _ready() -> void:
	Input.connect("joy_connection_changed", _on_joy_connection_changed)
	
	var joypads:Array = Input.get_connected_joypads()
	if !joypads.is_empty():
		_on_joy_connection_changed(0, true)
	else:
		_on_joy_connection_changed(0, false)
	
	SetUpKeys()

func SetUpKeys():
	$Keyboard/KeyboardKey_S.input = "move_down"
	$Keyboard/KeyboardKey_A.input = "move_left"
	$Keyboard/KeyboardKey_D.input = "move_right"
	$Keyboard/KeyboardKey_Space.input = "jump"
	$Keyboard/KeyboardKey_Pause.input = "pause"
	
	$PS4_Root/PS4/PS4_ThumbstickLeft.input = "Left"
	$PS4_Root/PS4/PS4_ThumbstickRight.input = "Right"
	#$PS4_Root/PS4/PS4_Face_Top.input = "jump"

func _process(delta: float) -> void:
	
	#var holdingJump = Input.is_action_pressed("jump")
	#var is_just_jumping = Input.is_action_just_pressed("jump") and get_window().has_focus()
	#if holdingJump:
		#PS4.position.y += 0.1
	
	ControllerShrinkGrow()

func _on_joy_connection_changed(device_id, connected):
	var controller = Input.get_joy_name(0)
	#print("Controller:  ", controller)
	
	if !connected:
		RemoveCurrentController(Keyboard)
		return
	
	
	elif controller == "Xbox One Controller":
		return
		# Untested
	
	elif controller == "Xbox 360 Controller":
		return
		# Untested
	
	elif controller.contains("Xbox"):
		return
		# Untested
	
	
	elif controller == "PS5 Controller":
		return
		# Untested
	
	elif controller == "PS4 Controller":
		RemoveCurrentController(PS4)
		return
	
	elif controller == "Wireless Controller":
		print("Controller:  Playstation 4 (Wireless)")
		return
		# Untested
	
	elif controller.contains("Playstation") or controller.contains("PS"):
		print("Controller:  Third Party PS Controller")
		return
		# Untested
	
	
	elif controller == "Nintendo Switch Controller":
		return
		# Untested
	
	elif controller == "Nintendo Switch Pro Controller":
		return
		# Connects but results are chaotic.
	
	elif controller == "Pro Controller":
		print("Controller:  Switch Pro (Wireless)")
		return
	
	elif controller.contains("Switch"):
		print("Controller:  Third Party SWITCH Controller")
		return
	
	
	elif controller == "Steam Deck Console":
		return
	
	elif controller == "Steam Controller":
		return
	
	elif controller.contains("Steam"):
		print("Controller:  Third Party STEAM Controller")
		return
	
	
	else:
		RemoveCurrentController(Unknown)
		print("Controller:  Unknown    ===    ", controller)
		return
		# Probably use a cheap unknown design, like the Mad Catz CAT9 and Logitec F310 controllers.

func RemoveCurrentController(newCon):
	print("Controller:  ", newCon)
	desiredCon = newCon
	
	if !firstTime:
		conReturning = true
	
	else:
		#Theres no active controller, skip the shrinking process.
		DisableVisibilityAll() # Remove controller (and incase bugged, anything else)
		NewController(desiredCon)

func NewController(newCon):
	#newCon.scale = Vector3.ZERO
	newCon.visible = true
	currentCon = newCon
	
	if !firstTime:
		conActivating = true
	
	else:
		currentCon.scale = Vector3(1,1,1)
		firstTime = false

func ControllerShrinkGrow():
	
	if conReturning:
		if !is_instance_valid(currentCon):
			#Theres no active controller, skip the shrinking process.
			DisableVisibilityAll() # Remove controller (and incase bugged, anything else)
			NewController(desiredCon)
			print("Controller: Return - No active controller")
		elif currentCon.scale.x <= 0.05:
			conReturning = false
			currentCon.scale = Vector3.ZERO
			DisableVisibilityAll() # Remove controller (and incase bugged, anything else)
			NewController(desiredCon)
			print("Controller: Return finished")
		else:
			# Shrink current controller until its near gone
			currentCon.scale -= Vector3(0.1, 0.1, 0.1)
			print("Controller: Returning")
	
	if conActivating:
		if currentCon.scale.x >= 1:
			conActivating = false
			currentCon.scale = Vector3(1,1,1)
		else:
			currentCon.scale += Vector3(0.1, 0.1, 0.1)

# Hides everything before displaying the next one.
func DisableVisibilityAll():
	Keyboard.visible = false
	PS4.visible = false
	PS5.visible = false
