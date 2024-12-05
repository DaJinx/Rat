extends Area3D

# ---------- VARIABLES ---------- #

# You can change these values from inspector!
@export_category("Properties")
@export var follow_speed : float = 6
const follow_ramp_up_speed : float = 0.1  # Faster it becomes while following you over time.
@export var amplitude := 0.2
@export var frequency := 4

var time_passed = 0
var is_in_close_range = false
var is_in_far_range = false

# Vector
var initial_position := Vector3.ZERO

@onready var player := get_tree().get_first_node_in_group("PlayerCharacter")

const BUTTON_BLUE = preload("res://Objects/Collectables/Buttons/Button_Blue.tres")
const BUTTON_GREEN = preload("res://Objects/Collectables/Buttons/Button_Green.tres")
const BUTTON_RED = preload("res://Objects/Collectables/Buttons/Button_Red.tres")
const BUTTON_YELLOW = preload("res://Objects/Collectables/Buttons/Button_Yellow.tres")
const BUTTON_AQUA = preload("res://Objects/Collectables/Buttons/Button_Aqua.tres")
const BUTTON_PINK = preload("res://Objects/Collectables/Buttons/Button_Pink.tres")
const BUTTON_PURPLE = preload("res://Objects/Collectables/Buttons/Button_Purple.tres")

# ---------- FUNCTIONS ---------- #

func _ready():
	initial_position = position
	
	var rng = RandomNumberGenerator.new()
	var rngMat = rng.randi_range(0, 6)
	
	if rngMat == 0:  $Mesh.material_override = BUTTON_BLUE
	elif rngMat == 1:  $Mesh.material_override = BUTTON_GREEN
	elif rngMat == 2:  $Mesh.material_override = BUTTON_RED
	elif rngMat == 3:  $Mesh.material_override = BUTTON_YELLOW
	elif rngMat == 4:  $Mesh.material_override = BUTTON_AQUA
	elif rngMat == 5:  $Mesh.material_override = BUTTON_PINK
	elif rngMat == 6:  $Mesh.material_override = BUTTON_PURPLE

func _process(delta):
	
	if !is_in_close_range:
		coin_hover(delta) # Call the coin_hover function
	
	if is_in_far_range:
		follow_player(delta, 0.25)
	
	if is_in_close_range:
		# Shrink
		var tween = create_tween()
		var s = 0.5  # Scale after tween
		var sp = 0.6  # Speed of tween
		tween.tween_property(self, "scale", Vector3(s, s, s), sp).set_ease(Tween.EASE_IN_OUT)
		
		follow_player(delta, 1)
	
	rotate_y(deg_to_rad(3))


# Coin Hover Animation
func coin_hover(delta):
	time_passed += delta
	
	var new_y = initial_position.y + amplitude * sin(frequency * time_passed)
	position.y = new_y

func follow_player(delta, speed):
	#var ray = $RayCast3D
	#const upOffset = Vector3(0, 1, 0)
	#ray.look_at( player.global_position + upOffset )
	#var dist = ray.global_position.distance_to(player.global_position) * -0.5
	#ray.target_position.y = dist
	#$RayCast3D/MeshInstance3D.position.z = dist
	#
	#if ray.is_colliding():
		#return
	
	
	
	position += global_position.direction_to(player.global_position) * (follow_speed * speed) * delta
	
	# If going at full speed, keeps speeding up.
	if speed == 1:
		follow_speed += follow_ramp_up_speed



# ---------- SIGNALS ---------- #

func _on_body_entered(body):
	# Delete The Coin and Add Score
	if body.is_in_group("PlayerCharacter"):
		GameManager.add_score()
		body.collect_coin()
		queue_free()

func _on_StrongMagnet_body_entered(body):
	if body.is_in_group("PlayerCharacter"):
		is_in_close_range = true
	else:
		is_in_close_range = false


func _on_LightMagnet_body_entered(body):
	if body.is_in_group("PlayerCharacter"):
		is_in_far_range = true
	else:
		is_in_close_range = false


func _on_LightMagnet_body_exited(body):
	if body.is_in_group("PlayerCharacter"):
		is_in_far_range = false
