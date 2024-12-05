extends Area3D


@onready var Player: PlayerCharacter = $".."
@onready var Camera: Node3D = $"../CameraRoot"

#@onready var detection_shape: CollisionShape3D = $DetectionShape
@onready var change_target_cooldown: Timer = $ChangeTargetCooldown
var target: LockOnComponent = null
var _targets_nearby: Array[LockOnComponent]


@export var enabled: bool = true
@export var target_detection_range: float = 20.0
@export var retain_distance: float = 25.0

@export_category("Changing Target")
@export var change_target_mouse_threshold: float = 60.0
@export var change_target_controller_threshold: float = 0.2
@export var change_target_wait_time: float = 0.5
@export var can_change_target = true


func _ready() -> void:
	change_target_cooldown.wait_time = change_target_wait_time
	#(detection_shape.shape as SphereShape3D).radius = target_detection_range

func _physics_process(delta: float) -> void:
	if not enabled:
		return
	
	#position = Player.position
	
	if target:
		var distance: float = Player.global_position.distance_to(target.global_position)
		if distance > retain_distance:
			target = null
			Lock()
	
	# change target with controller
	var controller_r_joystick_x: float = Input.get_joy_axis(0, JOY_AXIS_RIGHT_X)
	if can_change_target and abs(controller_r_joystick_x) > change_target_controller_threshold and target:
		
		if controller_r_joystick_x > 0:
			_change_target_right()
		else:
			_change_target_left()
		
		Lock()
		can_change_target = false
		change_target_cooldown.start()

# Gets inputs on left/right to see if should change target.
func _input(event: InputEvent) -> void:
	
	if not enabled:
		return
	
	# change target with mouse
	#if (event.get_axis("camera_left", "camera_right") != 0) and target:
	if event is InputEventMouseMotion and target:
		event = event as InputEventMouseMotion
		var current_mouse_pos: Vector2 = event.relative
		if Vector2.ZERO.distance_to(current_mouse_pos) > change_target_mouse_threshold and can_change_target:
			if current_mouse_pos.x > 0:
				_change_target_right()
			else:
				_change_target_left()
			
			Lock()
			can_change_target = false
			change_target_cooldown.start()

func LockInput():
	if target:
		target = null
	else:
		_choose_lock_on_target()
	
	Lock()



## ===== Collision ===== ##

# Gets all enemies that are nearby.
func _on_area_entered(area: Area3D) -> void:
	if area.name == "LockOnComponent":
		_targets_nearby.append(area)
		print("TARGET NEW: ", area, "   SIZE:  ", _targets_nearby.size())

# Deletes any enemies that leave range. 
func _on_area_exited(area: Area3D) -> void:
	if area.name == "LockOnComponent":
		_targets_nearby.erase(area)
		print("TARGET LEFT: ", area)

# If something is in the way between you and the closest target ??
func _can_see_target(t) -> bool:
	var can_see: bool = true
	var cam: Camera3D = get_viewport().get_camera_3d()
	
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(
		cam.global_position,
		t.global_position,
		1
	)
	var result: Dictionary = space_state.intersect_ray(query)
	
	if result.size() != 0 and result["collider"] != t.component_owner:
		can_see = false
	
	return can_see



## ===== Switch Target ===== ##

# Reset to nothing.
func reset_target() -> void:
	target = null
	Lock()

# Pick the next target available.
func _choose_new_target():
	_choose_lock_on_target()
	Lock()

# Changes to the closest target to the right.
func _change_target_right() -> void:
	var cam: Camera3D = get_viewport().get_camera_3d()
	var targets_in_frustum: Array[LockOnComponent] = _get_targets_in_front()
	
	if targets_in_frustum.size() == 0:
		target = null
		return
	targets_in_frustum.erase(target)
	
	var closest_dist: float
	var target_target: LockOnComponent = null
	var current_target_pos: Vector2 = cam.unproject_position(target.global_position)
	
	for t in targets_in_frustum:
		var pos: Vector2 = cam.unproject_position(t.global_position)
		var dist: float = current_target_pos.distance_to(pos)
	
		if pos.x > current_target_pos.x and (target_target == null or dist <= closest_dist):
			closest_dist = dist
			target_target = t
	
	target = target_target if target_target else target

# Changes to the closest target to the left.
func _change_target_left() -> void:
	var cam: Camera3D = get_viewport().get_camera_3d()
	var targets_in_frustum: Array[LockOnComponent] = _get_targets_in_front()
	
	if targets_in_frustum.size() == 0:
		target = null
		return
	targets_in_frustum.erase(target)
	
	var closest_dist: float
	var target_target: LockOnComponent = null
	var current_target_pos: Vector2 = cam.unproject_position(target.global_position)
	
	for t in targets_in_frustum:
		var pos: Vector2 = cam.unproject_position(t.global_position)
		var dist: float = current_target_pos.distance_to(pos)
		
		if pos.x < current_target_pos.x and (target_target == null or dist <= closest_dist):
			closest_dist = dist
			target_target = t
	
	target = target_target if target_target else target

# The cooldown ends, stops tapping direction scrolling through all of the enemies like 3 times.
func _on_change_target_cooldown_timeout() -> void:
	can_change_target = true

# The target is dead
func _target_destroyed(t: LockOnComponent) -> void:
	_targets_nearby.erase(t)
	
	var prev_target: LockOnComponent = t
	
	if not target:
		return
	
	#if  (
		#_dizzy_system.dizzy_victim and \
		#_dizzy_system.dizzy_victim.entity == target.component_owner and \
		#_dizzy_system.dizzy_victim.instability_component.full_instability_from_parry
	#) or \
	#(
		#_backstab_system.backstab_victim and \
		#_backstab_system.backstab_victim.entity == target.component_owner
	#):
		#
		#var timer: SceneTreeTimer = get_tree().create_timer(1.0)
		#timer.timeout.connect(
			#func():
				#if target == prev_target:
					#_choose_new_target()
		#)
		#
		#return
	
	_choose_new_target()

func Lock():
	Camera.LockOn(target) # Tell the camera "lock on to this guy".
	
	if target:
		%Combat.EnterLockMode(target)
	else:
		%Combat.ExitLockMode()



## ===== Organise Targets ===== ##

# Makes sure the targets are in front not behind to reduce the available targets ??
# Called from the left/right input.
func _get_targets_in_front() -> Array[LockOnComponent]:
	var targets: Array[LockOnComponent] = []
	var cam: Camera3D = get_viewport().get_camera_3d()
	
	for t in _targets_nearby:
		if not cam.is_position_behind(t.global_position) and _can_see_target(t):
			targets.append(t)
	
	return targets

# Select the target closest to the center of the screen.
func _choose_lock_on_target() -> void:
	# Get all the targets in view.
	var cam: Camera3D = get_viewport().get_camera_3d()
	var viewport_center: Vector2 = Vector2(get_viewport().size / 2)
	var targets_in_frustum: Array[LockOnComponent] = _get_targets_in_frustum()
	print("LOCK ON FRUS:  ", targets_in_frustum.size())
	
	# Create values
	var closest_dist: float
	var closest_target: LockOnComponent = null
	
	# See if theres any targets even to check, if no quit.
	if targets_in_frustum.size() == 0:
		target = null
		return
	
	# Best target to grab. (closest to the center)
	for t in targets_in_frustum:
		var dist: float = viewport_center.distance_to(cam.unproject_position(t.global_position))
		if closest_target == null or dist < closest_dist:
			closest_dist = dist
			closest_target = t
	
	# Finish with the value saved.
	target = closest_target

# Cone or pyramid outside of the camera for everything in view.
func _get_targets_in_frustum() -> Array[LockOnComponent]:
	var targets: Array[LockOnComponent] = []
	var cam: Camera3D = get_viewport().get_camera_3d()
	
	for t in _targets_nearby:
		if t != target and cam.is_position_in_frustum(t.global_position) and _can_see_target(t):
			targets.append(t)
	
	return targets
