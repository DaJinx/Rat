extends Node2D

@onready var player_2d: CharacterBody2D = $Player2D
#var camera:Camera2D
@onready var camera: Camera2D = $Camera2D

const margin = 40 # The outer radius the camera can go into. If the camera is too big, it will get stuck with a small number.
var currentRoom:Node2D
var rooms:Array[Node2D]
var roomTransition:bool


func _ready() -> void:
	#camera = player_2d.Camera2D
	
	# Add all the children of the Rooms node into an array.
	for _i in $Rooms.get_children():
		rooms.append(_i)
	
	# Get the current room.
	currentRoom = GetCurrentRoom()

func _process(delta: float) -> void:
	if !visible:
		return
	
	if roomTransition:
		# Transitioning
		if IsCameraInsideRect():
			RoomTransitionPause(false)
	else:
		# Not, but should transition?
		var playerRoom = GetCurrentRoom()
		if playerRoom != null  &&  playerRoom != currentRoom:
			currentRoom = playerRoom
			SetCameraLimitsToRoom(currentRoom)
			RoomTransitionPause(true)

func GetCurrentRoom() -> Node2D:
	var room = null
	
	for i in rooms:
		if i.playerInside:
			room = i
	
	return room

func RoomTransitionPause(paused:bool):
	roomTransition = paused
	get_tree().paused = paused
	print("IS OK NO MORE")
	
	#for i in get_children():
		#i.set_deferred("paused", paused)
		#i.paused = paused
		#i.time_scale = 0
		#i.set_process(paused)

func SetCameraLimitsToRoom(curRoom):
	var topLeft:Vector2 = curRoom.topLeft.global_position
	var botRight:Vector2 = curRoom.bottomRight.global_position
	
	camera.limit_top = topLeft.y
	camera.limit_left = topLeft.x
	camera.limit_bottom = botRight.y
	camera.limit_right = botRight.x

func IsCameraInsideRect():
	var topLeft = currentRoom.topLeft.global_position
	var botRight = currentRoom.bottomRight.global_position
	var currentTopLeft:Vector2 = camera.get_screen_center_position() - (camera.get_viewport_rect().size / 2) / camera.zoom
	var currentBotRight:Vector2 = camera.get_screen_center_position() + (camera.get_viewport_rect().size / 2) / camera.zoom
	
	var topLeftIsOk:bool = (currentTopLeft.x + margin) >= topLeft.x  &&  (currentTopLeft.y + margin) >= topLeft.y
	var botRightIsOk:bool = currentBotRight.x <= (botRight.x + margin)  &&  currentBotRight.y <= (botRight.y + margin)
	
	print("IS OK - TL: ", topLeftIsOk, " - BR: ", botRightIsOk, " - Both: ", topLeftIsOk && botRightIsOk)
	return topLeftIsOk && botRightIsOk
