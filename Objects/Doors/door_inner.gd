extends Node3D

@export var outerDoor:Node3D
var insideRoom:bool = false

# Activated when you enter the room, good for hiding and showing things for performance
func Entered():
	return
	insideRoom = true

func _on_area_3d_body_entered(body: Node3D) -> void:
	#Entered Room
	if !insideRoom:
		insideRoom = true
		
		# Sets the player's camera
		if body.CameraRoot: # Is it a player with a camera?
			var offset = Math.ForwardVector(self) * 5
			body.CameraRoot.EnterRoom(global_position + offset, global_rotation_degrees)
		
		return # Dont need to continue
	
	# Exiting Room
	else: 
		GlobalReferences.HUD.FadeOut()
		await get_tree().create_timer(0.5).timeout
		
		var offset = Math.ForwardVector(outerDoor) * 2 # Teleport to inside the door not middle of door frame.
		body.position = outerDoor.position + offset
		
		body.rotation = outerDoor.rotation
		insideRoom = false
		
		if body.CameraRoot:
			body.CameraRoot.ExitRoom()
		
		return
