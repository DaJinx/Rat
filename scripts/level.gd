extends Node

# ---------- VARIABLES ---------- #

@export var user_interface: Hud


# ---------- FUNCTIONS ---------- #


func _enter_tree() -> void:
	GlobalReferences.HUD = user_interface

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
