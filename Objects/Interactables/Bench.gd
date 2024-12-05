extends Node3D

@onready var sitLocRot_1 : Node3D = $SitLocRot_1
@onready var sitLocRot_2 : Node3D = $SitLocRot_2
var isIn1: bool = false
var isIn2: bool = false


func _on_sit_1_entered(body):
	if body.has_method("SitOnBench") and !isIn2:
		body.SitOnBench(sitLocRot_1.global_position, global_rotation_degrees.y)
		isIn1 = true

func _on_sit_1_exited(body):
	isIn1 = false

func _on_sit_2_entered(body):
	if body.has_method("SitOnBench") and !isIn1:
		body.SitOnBench(sitLocRot_2.global_position, global_rotation_degrees.y)
		isIn2 = true

func _on_sit_2_exited(body):
	isIn2 = false
