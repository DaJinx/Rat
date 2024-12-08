extends Node3D

var Gyro = SDLGyro.new()
var actCalibration = false

func _ready():
	Gyro.sdl_init()
	Gyro.controller_init()

func _process(_delta):
	Gyroscope()
	Accelerator()
	#print( "Gyro:  ", Gyro.get_calibrated_gyro() )
	#print( "Gyro:  ", Gyro.get_processed_acceleration() )

func _unhandled_input(event):
	#Pause to reset
	if event.is_action_pressed("pause"):
		if actCalibration==false:
			#$Label.visible=true
			Gyro.calibrate()
			actCalibration=true
	elif actCalibration==true:
		Gyro.stop_calibrate()
		#$Label.visible=false
		actCalibration=false

func Gyroscope():
	var orientation = Gyro.gamepad_polling()
	#quaternion = Quaternion(orientation[3], orientation[2], -orientation[1], orientation[0])
	quaternion = Quaternion(-orientation[1], orientation[3], orientation[2], orientation[0])
	# Up/Down, Turn, Barrel Roll, ??
	#rotation_degrees.x += -90

func Accelerator():
	return
	
	
	
	var processedAccel:Vector3 = Gyro.get_processed_acceleration()
	if abs(processedAccel.x) <= 1:
		processedAccel.x = 0
	if abs(processedAccel.y) <= 1:
		processedAccel.y = 0
	if abs(processedAccel.z) <= 1:
		processedAccel.z = 0
	#print("Cheese:   ", processedAccel)
	
	#var acceleration = Vector3.ZERO
	#
	#if processedAccel.length() >= 1:
		#acceleration = processedAccel * 0.01
	
	var acceleration = processedAccel * 0.01
	
	var newPos = position + Vector3(acceleration.y, acceleration.z, acceleration.x)
	position = lerp(position, newPos, 0.5)
	
	const maxDistance = 1
	position.x = clampf(position.x, position.x - maxDistance, position.x + maxDistance)
	position.y = clampf(position.y, position.y - maxDistance, position.y + maxDistance)
	position.z = clampf(position.z, position.z - maxDistance, position.z + maxDistance)
