class_name PlayerCombat
extends "player_shared.gd"

@export var is_attacking: bool = false
@export var damage_amount: float = 0.0
const INVULNERABILITY_TICK_DURATION: float = 10
var damage_tick: float = INVULNERABILITY_TICK_DURATION

@onready var hitbox_1: Area3D = $"../Character/BasicRat_ForPrototype/Armature/Skeleton3D/Swords_Unholstered/Hitbox1"
@onready var hitbox_2: Area3D = $"../Character/BasicRat_ForPrototype/Armature/Skeleton3D/Swords_Unholstered/Hitbox2"
var enemiesInBlade:Array
var enemiesDamagedThisAttack:Array # So it doesnt spam the same damage throught the swing

const groundPound_LaunchStrength = -15
const groundPound_OverTimeStrength = 2
const groundPound_BounceStrength = -2

var weaponOut:bool = false
var weaponLevel:int = 0

var lockedOn:bool = false
var targetedEnemy

func _ready() -> void:
	pass # Replace with function body.


func _process(delta: float) -> void:
	pass


# Function that the input references.
func Attack():
	if weaponOut:
		Attack_Blade()
	else:
		Attack_Blade()

# Faster attack when weapon isnt out.
func Attack_Claws():
	pass

# Attack with weapons.
func Attack_Blade():
	is_attacking = true
	
	Player.velocity = (Player.quaternion * -Vector3.FORWARD) * 20
	
	hitbox_1.monitoring = true
	hitbox_2.monitoring = true
	
	Player.rotation_degrees.y -= 90
	await get_tree().create_timer(0.025).timeout # Show the anticipation more than a frame
	
	var tween = get_tree().create_tween()
	var result = Player.rotation_degrees + Vector3(0, 360, 0)
	tween.tween_property(Player, "rotation_degrees", result, 0.3)
	
	hitbox_1.monitoring = false
	hitbox_2.monitoring = false
	
	
	#await get_tree().create_timer(0.0125).timeout
	
	await get_tree().create_timer(0.025).timeout
	Player.velocity = Vector3(0,0,0) # Ends dash
	await get_tree().create_timer(0.25).timeout
	is_attacking = false
	enemiesDamagedThisAttack.clear()

func EnterLockMode(target):
	targetedEnemy = target
	Camera.LockOn( targetedEnemy )
	$"../FlyPlaceholder".LockOn(targetedEnemy)
	PullOutWeapon()
	lockedOn = true
	Health.ToggleCombat()

func ExitLockMode():
	targetedEnemy = null
	$"../FlyPlaceholder".LockOff()
	HolsterWeapon()
	Camera.DisableLock()
	lockedOn = false
	Health.ToggleCombat()

func PullOutWeapon():
	weaponOut = true
	# Animation
	
	# Hide holstered mesh
	$"../Character/BasicRat_ForPrototype/Armature/Skeleton3D/Swords_Holstered".visible = false
	
	# Show unholstered weapon mesh
	$"../Character/BasicRat_ForPrototype/Armature/Skeleton3D/Swords_Unholstered".visible = true
	
	# Activate hitbox

func HolsterWeapon():
	weaponOut = false
	# Animation
	# Disable hitbox
	
	# Hide unholstered mesh
	$"../Character/BasicRat_ForPrototype/Armature/Skeleton3D/Swords_Unholstered".visible = false
	
	# Show holstered weapon mesh
	$"../Character/BasicRat_ForPrototype/Armature/Skeleton3D/Swords_Holstered".visible = true
	
	# Deactivate hitbox


func GroundPound():
	return
	Player.gravity = groundPound_LaunchStrength
	StateMachine.currentState = StateMachine.states.GROUND_POUNDING
	is_attacking = true


func _on_hitbox_1_body_entered(body: Node3D) -> void:
	if body.has_method("Damage")  and  enemiesDamagedThisAttack.count(body) == 0:
		body.Damage()
		
		# Record a reference for that swing so doesnt spam.
		enemiesDamagedThisAttack.append(body)
	else:
		print("ENEMY  :", enemiesDamagedThisAttack.count(body))

func _on_hitbox_2_body_entered(body: Node3D) -> void:
	pass # Replace with function body.

func _on_hitbox_1_body_exited(body: Node3D) -> void:
	pass # Replace with function body.

func _on_hitbox_2_body_exited(body: Node3D) -> void:
	pass # Replace with function body.
