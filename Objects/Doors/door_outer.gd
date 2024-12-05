extends Node3D

@export var innerDoor:Node3D
@onready var door_1: Node3D = $Door1_Root
@onready var door_2: Node3D = $Door2_Root
var isInsideRoom:bool = false


func _on_area_3d_body_entered(body: Node3D) -> void:
	if !isInsideRoom:
		
		GlobalReferences.HUD.FadeOut()
		await get_tree().create_timer(0.5).timeout
		
		body.position = innerDoor.position
		body.rotation = innerDoor.rotation
		
		isInsideRoom = true
		innerDoor.Entered()
		return
	
	else:
		isInsideRoom = false
		return


func _on_nearby_area_body_entered(body: Node3D) -> void:
	if isInsideRoom:
		return # Doors already open.
	
	# Open doors
	var tween1 = get_tree().create_tween()
	tween1.tween_property(door_1, "rotation_degrees", Vector3(0, -162.6, 0), 0.2)
	
	var tween2 = get_tree().create_tween()
	tween2.tween_property(door_2, "rotation_degrees", Vector3(0, 162.6, 0), 0.2)
	print("DOOR")


func _on_nearby_area_body_exited(body: Node3D) -> void:
	if isInsideRoom:
		return # Dont close while still is inside.
	
	# Close doors
	var tween1 = get_tree().create_tween()
	tween1.tween_property(door_1, "rotation_degrees", Vector3.ZERO, 0.2)
	
	var tween2 = get_tree().create_tween()
	tween2.tween_property(door_2, "rotation_degrees", Vector3.ZERO, 0.2)
