extends Node3D

@onready var model = $Mesh
var modelDefaultScale

func _ready():
	modelDefaultScale = model.scale

func _process(delta):
	model.scale = lerp(model.scale, modelDefaultScale, 0.5)

func Stomped():
	model.scale = Vector3(1.25, 0.25, 1.25)
	print("Y")
