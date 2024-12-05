class_name PlayerHealth
extends "player_shared.gd"

#@onready var Player: PlayerCharacter = $".."

@export var healthMax : int = 8
var health : int = healthMax
const deadZone = -40
var dead:bool = false

@onready var roach: MeshInstance3D = $"../Character/RoachPlaceholder"
const ROACH_MAT_NOT_COMBAT = preload("res://Player/Assets/Roach_NotCombat.tres")
const ROACH_MAT_1 = preload("res://Player/Assets/Roach_1.tres")
const ROACH_MAT_2 = preload("res://Player/Assets/Roach_2.tres")
const ROACH_MAT_3 = preload("res://Player/Assets/Roach_3.tres")
const ROACH_MAT_4 = preload("res://Player/Assets/Roach_4.tres")
const ROACH_MAT_5 = preload("res://Player/Assets/Roach_5.tres")
const ROACH_MAT_6 = preload("res://Player/Assets/Roach_6.tres")
const ROACH_MAT_7 = preload("res://Player/Assets/Roach_7.tres")
const ROACH_MAT_8 = preload("res://Player/Assets/Roach_8.tres")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func Damage(amount, hitLoc, launchStrength):
	if dead:
		return
	
	health -= amount
	SetRoachMat()
	print("HP:  ", health)
	
	#Player.velocity = hitLoc.direction_to(Player.global_position) * -launchStrength
	Player.velocity = Player.global_position.direction_to(hitLoc) * launchStrength
	Player.velocity.y += 5
	
	if health == 0:
		Death()

# Death on being to low.
func OffStageCheck():
	if Player.global_position.y < deadZone:
		Death()
		print("DEADZONE DEATH")

func Death():
	dead = true
	
	await get_tree().create_timer(2).timeout
	Respawn()

func Respawn():
	get_tree().reload_current_scene()

func ToggleCombat():
	SetRoachMat()

func SetRoachMat():
	if !Combat.lockedOn:
		roach.set_material_override(null)
		return
	
	if health == 1:
		roach.set_material_override(ROACH_MAT_1)
	elif health == 2:
		roach.set_material_override(ROACH_MAT_2)
	elif health == 3:
		roach.set_material_override(ROACH_MAT_3)
	elif health == 4:
		roach.set_material_override(ROACH_MAT_4)
	elif health == 5:
		roach.set_material_override(ROACH_MAT_5)
	elif health == 6:
		roach.set_material_override(ROACH_MAT_6)
	elif health == 7:
		roach.set_material_override(ROACH_MAT_7)
	elif health == 8:
		roach.set_material_override(ROACH_MAT_8)
