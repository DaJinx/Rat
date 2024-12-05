extends MeshInstance3D

@onready var player: PlayerCharacter = $".."
@onready var restTarget: Marker3D = $"../FlyPosition"
var target
var isResting:bool = true
var lockedOn:bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position = restTarget.global_position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if !lockedOn:
		var offset:Vector3
		if isResting:
			target = restTarget
			if Math.IsMoving(player.velocity):
				offset.y = 0.4
		else:
			offset.y = 0.8
		
		position = lerp(position, target.global_position + offset, 0.1)
	
	else:
		if target.flyOffset:
			var offset:Vector3 = Vector3(0, target.flyOffset, 0)
			position = lerp(position, target.global_position + offset, 0.1)

func LockOn(newTarget):
	target = newTarget
	isResting = false
	lockedOn = true

func LockOff():
	target = player
	isResting = true
	lockedOn = false
