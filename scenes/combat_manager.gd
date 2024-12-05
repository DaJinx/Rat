extends Node3D

@export var EnemiesToSpawn : Array[Enemies] = [Enemies.GRUNT, Enemies.GRUNT]

enum Enemies{ GRUNT, RANGER }

@onready var area := %AreaCollisionShape
@onready var Grunt := preload("res://Scenes/enemy.tscn")
@onready var Ranger := preload("res://Scenes/enemy.tscn")

const combatAreaDistance : float = 14

var isInCombat : bool = false
var enemiesAlive := []
var spawnOffset : float = 1  # How much inwards they have to spawn, making sure they dont spawn on the edge.

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$EdgeDisplayMesh_1.global_position = position + Vector3( combatAreaDistance, 0, 0 )
	$EdgeDisplayMesh_2.global_position = position + Vector3( -combatAreaDistance, 0, 0 )
	$EdgeDisplayMesh_3.global_position = position + Vector3( 0, 0, combatAreaDistance )
	$EdgeDisplayMesh_4.global_position = position + Vector3( 0, 0, -combatAreaDistance )
	area.shape.size = Vector3(combatAreaDistance, 10, combatAreaDistance)
	
	SpawnEnemies()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !isInCombat:
		return
	
	pass

func SpawnEnemies():
	for n in EnemiesToSpawn.size():
		var enemy
		if EnemiesToSpawn[n] == Enemies.GRUNT:
			enemy = Grunt.instantiate()
		if EnemiesToSpawn[n] == Enemies.RANGER:
			enemy = Ranger.instantiate()
		self.add_child(enemy)
		
		var rng = RandomNumberGenerator.new()
		var offsetX = rng.randf_range( -combatAreaDistance + spawnOffset,  combatAreaDistance - spawnOffset )
		var offsetZ = rng.randf_range( -combatAreaDistance + spawnOffset,  combatAreaDistance - spawnOffset )
		enemy.global_position = position + Vector3( offsetX, 0, offsetZ )
