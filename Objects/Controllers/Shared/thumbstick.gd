extends Node3D

@export var input = ""
const highlight_material = preload("res://Objects/Controllers/Shared/button_hightlight.tres")  # Load the material

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if input == "Left":
		var x = Input.get_axis("move_up", "move_down")
		var y = Input.get_axis("move_left", "move_right")
		x *= 0.4 # Makes it not turn 90 degrees.
		y *= 0.4 # Makes it not turn 90 degrees.
		rotation.x = lerpf(rotation.x, x, 0.5)
		rotation.y = lerpf(rotation.y, y, 0.5)
		
		if (x+y) != 0:
			$ThumbstickMesh.set_surface_override_material(0,highlight_material)
		else:
			$ThumbstickMesh.set_surface_override_material(0,null)
	
	if input == "Right":
		var x = Input.get_axis("camera_up", "camera_down")
		var y = Input.get_axis("camera_left", "camera_right")
		x *= 0.4 # Makes it not turn 90 degrees.
		y *= 0.4
		rotation.x = lerpf(rotation.x, x, 0.5)
		rotation.y = lerpf(rotation.y, y, 0.5)
		
		if (x+y) != 0:
			$ThumbstickMesh.set_surface_override_material(0,highlight_material)
		else:
			$ThumbstickMesh.set_surface_override_material(0,null)
