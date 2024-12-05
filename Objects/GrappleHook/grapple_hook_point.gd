extends Node3D

@onready var joint: PinJoint3D = $PinJoint3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func EnableIcon(shouldEnable:bool):
	pass

func Attached(character):
	joint.node_b = character
	## parent to this?
	#character.rotation = 
