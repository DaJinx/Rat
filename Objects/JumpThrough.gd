extends Node3D

#@onready var collision = $StaticBody3D/CollisionShape3D
#@onready var mesh = $Mesh
var isBelow = false
var isAbove = false
var modelDefaultScale
var defaultHeight : float = position.y

var cannotStomp = false
var sink = false
var raise = false
var sinkSpeed : float = 0.05
var sinkAmount : float = 0.5


#func _ready():
	#collision.set_deferred("disabled", true)
	#modelDefaultScale = mesh.scale
	#defaultHeight = position.y
#
#func _process(delta):
	#mesh.scale = lerp(mesh.scale, modelDefaultScale, 0.1)
	#
	##if sink:
		##if !equal_approx(position.y, defaultHeight - sinkAmount, 0.1):
			##position.y = lerp(position.y, defaultHeight - sinkAmount, sinkSpeed)
			##print("Cloud: ", position.y)
		##else:
			##sink = false
			##raise = true
			##print("Cloud: RAISE")
	##if raise:
		##if !equal_approx(position.y, defaultHeight, 0.01):
			##position.y = lerp(position.y, defaultHeight, sinkSpeed)
			##print("Cloud: ", position.y)
		##else:
			##sink = false
			##raise = false
			##cannotStomp = false
			##print("Cloud: RETURNED")

#func StaticStomped():
	##if cannotStomp:
		##return
	#
	#mesh.scale = modelDefaultScale * Vector3(1.15, 0.85, 1.15)
	#raise = false
	#sink = true
	#cannotStomp = true
#
#func _BelowArea_entered(body):
	#collision.set_deferred("disabled", true)
	#isBelow = true
#
#func _BelowArea_exited(body):
	#isBelow = false
	#
	#if isAbove:
		#collision.set_deferred("disabled", false)
#
#func _AboveArea_entered(body):
	#isAbove = true
	#
	#if !isBelow:
		#collision.set_deferred("disabled", false)
#
#func _AboveArea_exited(body):
	#isAbove = false
#
## Custom "is_equal_aprox" to change the leniency.
#func equal_approx(a: float, b: float, l: float) -> bool:
	#return abs( a - b ) < l
