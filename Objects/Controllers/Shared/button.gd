extends Node3D

@export var input = ""
#@onready var root = $KeyRoot
@export var buttonName = ""
var button:MeshInstance3D
const regular_material = preload("res://Objects/Controllers/Shared/button_normal.tres")
const highlight_material = preload("res://Objects/Controllers/Shared/button_hightlight.tres")
@export var texture = preload("res://Objects/Controllers/Models/PS4/gltf_embedded_11_2.png")

@export var clickDirection : directions = directions.Z
enum directions {X, Y, Z}
@export var inverted : bool = false
var originalPos:Vector3

@export var clickAmount : float = 0.1
@export var colour:Color = Color( 0.03, 0.03, 0.03 )
var mat # Make unique material so it doesnt set every button to this colour.


func _ready():
	if !buttonName:
		return
	button = get_node(buttonName)
	originalPos = position
	
	if is_instance_valid(button):
		mat = regular_material.duplicate() 
		mat.albedo_texture = texture
		mat.albedo_color = colour
		button.set_surface_override_material(0, mat)
		#button.get_surface_override_material(0).albedo_color = colour

func _unhandled_input(event):
	if !is_instance_valid(button)  or  !input:
		return
	
	if event.is_action_pressed(input):
		#root.position.y = lerpf(root.position.y, -0.15, 0.5)
		
		if inverted:
			clickAmount *= -1
		
		if clickDirection == directions.X:
			position.x = lerpf(position.x, originalPos.x - clickAmount, 0.5)
		if clickDirection == directions.Y:
			position.y = lerpf(position.y, originalPos.y - clickAmount, 0.5)
		if clickDirection == directions.Z:
			position.z = lerpf(position.z, originalPos.z - clickAmount, 0.5)
		
		button.set_surface_override_material(0,highlight_material)
		#button.get_surface_override_material(0).albedo_color = Color(1,1,1)
	
	elif event.is_action_released(input):
		position = lerp(position, originalPos, 0.5)
		
		button.set_surface_override_material(0,mat)
		#button.get_surface_override_material(0).albedo_color = colour
		#button.set_surface_override_material(0,null)
