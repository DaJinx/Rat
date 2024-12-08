extends Node3D

# Looking at target
@onready var look_target
@onready var skeleton = $Armature/Skeleton3D
@onready var combat: PlayerCombat = %Combat
@onready var head_rot: Marker3D = $"../HeadRot"
var new_rotation
var targetedEnemy

# Ears
@export var ear_linear_spring_stiffness:float = 1200.0
@export var ear_linear_spring_damping:float = 40.0
@export var ear_angular_spring_stiffness:float = 4000.0
@export var ear_angular_spring_damping:float = 80.0
var ear_bones

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Probably something to do with skins.
	
	#skeleton.physical_bones_start_simulation()
	#ear_bones = skeleton.get_children().filter(filter(func(x): return x is PhysicalBone3D))
	
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if combat.targetedEnemy:
		LookAtTarget(delta)
	else:
		ResetLookAt()

func LookAtTarget(delta):
	# Gets new values
	var neck_bone = skeleton.find_bone("Head")
	head_rot.look_at(combat.targetedEnemy.global_position, Vector3.UP, true)
	head_rot.rotation_degrees.x = clampf(head_rot.rotation_degrees.x, -90, 90)
	head_rot.rotation_degrees.y = clampf(head_rot.rotation_degrees.y, -90, 90)
	
	var newRot = Quaternion.from_euler(head_rot.rotation) # Converts to quaternion
	new_rotation = lerp(new_rotation, newRot, 0.1) # Smooth rotation
	
	skeleton.set_bone_pose_rotation(neck_bone, new_rotation)

func ResetLookAt():
	var neck_bone = skeleton.find_bone("Head")
	head_rot.rotation = Vector3.ZERO
	new_rotation = Quaternion.from_euler(head_rot.rotation)
	skeleton.set_bone_pose_rotation(neck_bone, new_rotation)

func hookes_law(displacement:Vector3, current_velocity:Vector3, stiffness:float, damping:float) -> Vector3:
	return (stiffness * displacement) - (damping * current_velocity)
