extends Node3D

enum attackStates { ANTICIPATION, ACTION, RECOVERY}
enum attackModes { HOR_CLOCKWISE, HOR_ANTICLOCKWISE, VERT, ANGLED_1, ANGLED_2, ANGLED_3, ANGLED_4 }
@export var currentState : attackStates
@export var currentMode : attackModes
@onready var weapon: Node3D = $WeaponRoot
var attackLow:bool = false
var attackRotationSpeed = 20
var count:int = 0 
var damagedThisAttack:bool = false
const anticipationTime = 0.6
const recoveryTime = 0.5


func _ready() -> void:
	Anticipation()

func _process(delta: float) -> void:
	if currentState == attackStates.ACTION:
		Action()

func Anticipation():
	var rng = RandomNumberGenerator.new()
	var randomChance3 = rng.randi_range(0, 2)
	if randomChance3 == 0:
		weapon.position.y = 3.183
		attackLow = false
	else:
		weapon.position.y = 1
		attackLow = true
	
	var randomChance2 = rng.randi_range(0, 6)
	weapon.rotation_degrees = Vector3.ZERO
	if randomChance2 == 0:
		currentMode = attackModes.HOR_CLOCKWISE
		weapon.rotation_degrees.y = 100
	elif randomChance2 == 1:
		currentMode = attackModes.HOR_ANTICLOCKWISE
		weapon.rotation_degrees.y = -100
	
	elif randomChance2 == 2 and !attackLow:
		currentMode = attackModes.VERT
		weapon.rotation_degrees.x = -90
	
	elif randomChance2 == 3 and !attackLow:
		currentMode = attackModes.ANGLED_1
		weapon.rotation_degrees.x = -40
		weapon.rotation_degrees.y = -60
	elif randomChance2 == 4 and !attackLow:
		currentMode = attackModes.ANGLED_2
		weapon.rotation_degrees.x = -40
		weapon.rotation_degrees.y = 60
	elif randomChance2 == 5 and !attackLow:
		currentMode = attackModes.ANGLED_3
		weapon.rotation_degrees.x = 40
		weapon.rotation_degrees.y = -60
	elif randomChance2 == 6 and !attackLow:
		currentMode = attackModes.ANGLED_4
		weapon.rotation_degrees.x = 40
		weapon.rotation_degrees.y = 60
	
	## Incase nothing above, just do this by default
	else:
		Anticipation()
		return
	
	await get_tree().create_timer(anticipationTime).timeout
	currentState = attackStates.ACTION

func Action():
	if currentMode == attackModes.HOR_CLOCKWISE:
		weapon.rotation_degrees.y -= attackRotationSpeed
	
	elif currentMode == attackModes.HOR_ANTICLOCKWISE:
		weapon.rotation_degrees.y += attackRotationSpeed
	
	elif currentMode == attackModes.VERT:
		weapon.rotation_degrees.x += attackRotationSpeed
	
	elif currentMode == attackModes.ANGLED_1:
		weapon.rotation_degrees.x += attackRotationSpeed * 0.6
		weapon.rotation_degrees.y += attackRotationSpeed * 1
	
	elif currentMode == attackModes.ANGLED_2:
		weapon.rotation_degrees.x += attackRotationSpeed * 0.6
		weapon.rotation_degrees.y -= attackRotationSpeed * 1
	
	elif currentMode == attackModes.ANGLED_3:
		weapon.rotation_degrees.x -= attackRotationSpeed * 0.6
		weapon.rotation_degrees.y += attackRotationSpeed * 1
	
	elif currentMode == attackModes.ANGLED_4:
		weapon.rotation_degrees.x -= attackRotationSpeed * 0.6
		weapon.rotation_degrees.y -= attackRotationSpeed * 1
	
	count += 1
	
	if count == 10:
		count = 0
		Recovery()

func Recovery():
	currentState = attackStates.RECOVERY
	damagedThisAttack = false
	await get_tree().create_timer(recoveryTime).timeout
	currentState = attackStates.ANTICIPATION
	Anticipation()


func _on_area_3d_body_entered(body: Node3D) -> void:
	if !damagedThisAttack  and  body.name == "Player":
		body.Health.Damage(1, $WeaponRoot/MeshInstance3D2/Area3D.global_position, 20)
		damagedThisAttack = true

func Damage():
	$MeshInstance3D/MeshInstance3D2.position.y = 0.2
	print("ENEMY DAMAGED")
	await get_tree().create_timer(1).timeout
	$MeshInstance3D/MeshInstance3D2.position.y = 0.55
