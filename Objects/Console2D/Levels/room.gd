@tool
extends Node2D

@onready var topLeft: Node2D = $TopLeft
@onready var bottomRight: Node2D = $BottomRight
@onready var colShape: CollisionShape2D = $Area2D/CollisionShape2D
@export var size:Vector2 = Vector2(250,250)
var playerInside = false

func _ready() -> void:
	if not Engine.is_editor_hint():
		SetShape()

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		SetShape()

func SetShape():
	colShape.shape.size = size
	topLeft.position = Vector2(-(size.x / 2),  -(size.y / 2))
	bottomRight.position = Vector2(size.x / 2,  size.y / 2)

func _on_area_2d_body_entered(body: Node2D) -> void:
	playerInside = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	playerInside = false
