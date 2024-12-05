extends Node3D

func _on_area_3d_body_entered(body: Node3D) -> void:
	if !body.CameraRoot:
		return
	
	body.CameraRoot.EnterCavern($CameraTransform.global_position, $CameraTransform.global_rotation)


func _on_area_3d_body_exited(body: Node3D) -> void:
	if !body.CameraRoot:
		return
	
	body.CameraRoot.ExitCavern()
