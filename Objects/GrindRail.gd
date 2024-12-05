extends Node3D

@export var move_speed := 4.0
@export var point_total: int = 20

@onready var path_3d = $"."
#@onready var path_curve = curve

var connectedPlayer : CharacterBody3D
var playerMesh : Node3D
var pointCount: float = 0
var direction := 1
var hasSpawnedPoints = false


# Called when the node enters the scene tree for the first time.
func _ready():
	#%Path3D/PathFollow3D
	populate_rail()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	#pass
	%PathFollow3D.progress += ( move_speed * direction ) * delta
	print("Progress:", %PathFollow3D.progress)
	if is_instance_valid(connectedPlayer):
		connectedPlayer.global_position = %PathFollow3D.global_position
		playerMesh.global_rotation = %PathFollow3D.global_rotation
		playerMesh.global_rotation_degrees.y += 90  # Offset so you dont go inside rail.

func populate_rail():
	#var path_length = curve.get_baked_length()
	#var spacing = path_length / 19
	#var current_distance = 0
	#var staring_progress = 0.001
	#
	#for i in range(point_total):
		#var object_instance = rail_follower.instantiate()
		#object_instance.progress = staring_progress
		#add_child(object_instance)
		#staring_progress += 5
		#current_distance += spacing
		#pointCount += 1.0
		#if i == point_total:
			#hasSpawnedPoints = true
	pass

func EnterRail(player, mesh):
	%PathFollow3D.progress = self.curve.get_closest_offset(player.global_position)
	
	# Determine if it should go reverse direction.
	var rotDiff
	var meshY = mesh.global_rotation_degrees.y
	var path = %PathFollow3D.global_rotation_degrees.y
	
	#var rotDiff = rad_to_deg(mesh.global_rotation_degrees.angle_to(%PathFollow3D.global_rotation_degrees))
	if direction == 1:
		rotDiff = meshY - path
	if direction == -1:
		rotDiff = meshY - ConvertRot(path + 180)
	#var rotDiff = abs(( mesh.global_rotation_degrees.y ) - ( %PathFollow3D.global_rotation_degrees.y ))
	print("Hoi: ", rotDiff, "     ", meshY, "    ", path, "    " ,ConvertRot(path + 180))
	#if rotDiff > 90:
	if rotDiff > 90 or rotDiff < -90:
		direction *= -1
	
	#connectedPlayer = player
	#playerMesh = mesh

func LeaveRail():
	connectedPlayer = null

func ConvertRot(rot):
	var rot2 = rot
	if rot > 180 or rot < -180:
		rot2 *= -1
	return rot2
