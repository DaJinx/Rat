extends Node3D
@onready var mesh = $Skeleton3D/CharacterMesh

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Fade out over time
	# Dont need to worry about the other materials because they all are a dupe of the same one.
	# Reminder: Local to scene must be ticked for every ghost not to share the same transparency (starting from 0 after the first)
	var mat1 = mesh.get_surface_override_material(0)
	
	mat1.albedo_color.a -= 0.001
	
	mesh.set_surface_override_material(0, mat1)
	
	if mat1.albedo_color.a <= 0:
		self.queue_free()
