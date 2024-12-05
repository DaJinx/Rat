extends Node3D

@onready var screen: Sprite3D = $Screen
@onready var retro_game_2d: Node2D = $Screen/SubViewport/RetroGame2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_3d_body_entered(body: Node3D) -> void:
	var duration = 1
	body.SwitchCamera($Camera3D, duration)
	body.controlled = false
	await get_tree().create_timer(duration).timeout
	screen.visible = true
	retro_game_2d.PlayerEntered()

func _on_area_3d_body_exited(body: Node3D) -> void:
	pass # Replace with function body.
