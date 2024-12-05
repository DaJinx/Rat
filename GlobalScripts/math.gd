extends Node


# Is moving, not falling.
func IsMoving(velocity):
	return abs(velocity.z) > 0.3 || abs(velocity.x) > 0.3

func ForwardVector(node:Object):
	var aim = node.get_global_transform().basis
	var forward = -aim.z
	return forward

func BackwardVector(node:Object):
	var aim = node.get_global_transform().basis
	var backward = aim.z
	return backward

func RightVector(node:Object):
	var aim = node.get_global_transform().basis
	var right = aim.x
	return right

func LeftVector(node:Object):
	var aim = node.get_global_transform().basis
	var left = -aim.x
	return left

func UpVector(node:Object):
	var aim = node.get_global_transform().basis
	var up = aim.y
	return up

# Custom "is_equal_aprox" to change the leniency.
func equal_approx(a: float, b: float, l: float) -> bool:
	return abs( a - b ) < l

# Distance between two values, does not convert negative numbers into positive.
# But the result itself is positive.
func compareValues_Exact(val1, val2):
	# This function is good for cases like comparing distance between rotation axis.
	# Like "the mesh is 20 degrees different more than this other thing" despite one being in the negative value
	return abs(( val1 ) - ( val2 ))

# Compare the absolute value of difference of their respective absolute value.
# Each value is turned positive, compared then result is also turned positive.
func compareValues_Positive(val1, val2):
	return abs(abs( val1 ) - abs( val2 ))
