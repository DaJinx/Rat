class_name CameraController
extends Node


var transitioning := false
@onready var camera3D: Camera3D = $Camera3D

func SwitchCamera(from, to) -> void:
	from.current = false
	to.current = true

func transitionCamera3D(from:Camera3D, to:Camera3D, duration:float = 1.0) -> void:
	if transitioning: return
	
	
	
	#Copy the parameters of the first camera
	camera3D.fov = from.fov
	camera3D.cull_mask = from.cull_mask
	
	# Move our transition camera to the first camera position
	camera3D.global_transform = from.global_transform
	camera3D.fov = from.fov
	
	# Make out transition camera current
	camera3D.current = true
	transitioning = true
	
	# Move to the second camera, while also adjusting the parameters to match the second camera.
	# Needs to be seperat functions because they also act as built in delays. If played in same function, 
	# will do 1 at a time.
	TweenTransform(from, to, duration)
	TweenFOV(from, to, duration)
	
	#if from.projection == 
	#tween.tween_property(camera3D, "fov", to.fov, duration)
	
	# Wait for the tween to complete
	await get_tree().create_timer(duration).timeout
	#await tween.finished
	
	# Make the second camera current
	to.current = true
	transitioning = false

func TweenTransform(from:Camera3D, to:Camera3D, duration:float = 1.0):
	var tween:Tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_CUBIC)
	
	tween.tween_property(camera3D, "global_transform", to.global_transform, duration)

func TweenFOV(from:Camera3D, to:Camera3D, duration:float = 1.0):
	var tween:Tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_CUBIC)
	
	tween.tween_property(camera3D, "fov", to.fov, duration)
