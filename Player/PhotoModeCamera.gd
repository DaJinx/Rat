extends Camera3D


var activated:bool = false
var player:CharacterBody3D # For possessing back when done.
var originalCam
var speed:float = 5
var rotationTarget:Vector3
var lowestPerspective:float = 50
var highestPerspective:float = 90

@export var mouse_sensitivity := 0.2
@export var controller_sensitivity := 1.5


func Activate(thePlayer:CharacterBody3D, cam):
	player = thePlayer
	originalCam = cam
	
	global_position = originalCam.global_position
	global_rotation = originalCam.global_rotation
	
	player.controlled = false
	
	activated = true
	current = true


func _input(event: InputEvent) -> void:
	MouseInputs(event)
	
	if Input.is_action_just_pressed("attack"):
		TakePhoto()
	
	# Exit from photo mode
	if Input.is_action_just_pressed("pause"):
		# Possess back
		player.controlled = true
		originalCam.current = true
		
		# Delete self
		self.queue_free()


func _physics_process(delta: float) -> void:
	ControllerInputs(delta)
	Move(delta) # Needs to be here for controller inputs
	Rotate()


## Movement
func Move(delta):
	var input = Vector3.ZERO
	input.x = Input.get_axis("move_left", "move_right")
	input.z = Input.get_axis("move_up", "move_down")
	input.y = Input.get_axis("dash", "jump")
	
	var movementInput = input.rotated(Vector3.UP, rotation.y).normalized()
	position += movementInput * speed * delta

func Rotate():
	rotation_degrees.x = rotationTarget.x
	rotationTarget.x = clamp(rotation_degrees.x, -highestPerspective, lowestPerspective)
	rotation_degrees.x = clamp(rotation_degrees.x, -highestPerspective, lowestPerspective)
	
	rotation_degrees.y = rotationTarget.y
	rotationTarget.y = wrapf(rotation_degrees.y, 0, 360)
	rotation_degrees.y = wrapf(rotation_degrees.y, 0, 360)

## Input
func ControllerInputs(delta):
	var rot := Vector2.ZERO
	rot.x = Input.get_axis("camera_down", "camera_up")
	rot.y = Input.get_axis("camera_right", "camera_left")
	rot *= controller_sensitivity
	
	rotationTarget += Vector3(rot.x, rot.y, 0)

func MouseInputs(event):
	if event is InputEventMouseMotion:
		rotationTarget.x -= event.relative.y * mouse_sensitivity
		rotationTarget.y -= event.relative.x * mouse_sensitivity


func TakePhoto():
	var img = get_viewport().get_texture().get_image()
	var unix = str(Time.get_unix_time_from_system())
	img.save_png("user://" + "Rat_" + unix + ".png")

# Incase a screenshot viewer ingame.
func get_screenshot() -> ImageTexture:
		return ImageTexture.create_from_image(get_viewport().get_texture().get_image())
