extends "player_shared.gd"
#extends Node

@onready var player: CharacterBody3D = $".."

const MOVE_WAS_TELEPORT_THRESHOLD = 3.0
@export var target_pos: Vector3
@export var target_dir: float = deg_to_rad(0)
@export var sync_velocity: Vector3
var last_move_time = -INF


## Stuff are commented out just to play the game without errors, will need redo'ing probably.

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	target_pos = player.position
	target_dir = player.rotation.y


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	return
	
	## Code is from the portal code and is not tested.
	
	if (target_pos - player.position).length() >= MOVE_WAS_TELEPORT_THRESHOLD and _check_if_teleport_was_teleport_to_other_portal(target_pos):
		# Continue moving player smoothly at expected speed as they go through portal
		# Without this, the teleport code in the Portal will cause a teleport to trigger and
		# force move the player to the latest position
		_move_self_to_other_portal()
		
		# stairs handling
		if sync_velocity.y == 0 and player.position.y != target_pos.y:
			player.position.y = target_pos.y
		var move_vec = target_pos - player.position
		player.rotation.y = target_dir
		
		if move_vec.length() < MOVE_WAS_TELEPORT_THRESHOLD:
			if move_vec.length() > 0:
				var move_this_frame = move_vec.normalized() * delta * sync_velocity.length()
				if move_this_frame.length() >= move_vec.length() or move_this_frame.length() == 0:
					player.position = target_pos
				else:
					player.position += move_this_frame
				last_move_time = Time.get_ticks_msec()
		else:
			player.position = target_pos
	
	
	_rotate_step_up_separation_ray() 
	_snap_down_to_stairs_check()
	target_pos = player.position
	target_dir = player.rotation.y
	sync_velocity = player.velocity




var _portal_tracking_us = null

func _on_portal_tracking_enter(portal):
	_portal_tracking_us = portal

func _on_portal_tracking_leave(_portal):
	_portal_tracking_us = null

func _check_if_teleport_was_teleport_to_other_portal(to_position):
	if not _portal_tracking_us:
		return false
	var position_rel_to_cur_portal = _portal_tracking_us.global_transform.affine_inverse() * player.global_position
	
	var to_position_offset = to_position - self.position
	var after_teleport_global_pos = self.global_position + to_position_offset
	
	var position_rel_to_other_portal = _portal_tracking_us.other_portal.global_transform.affine_inverse() * after_teleport_global_pos
	
	if (position_rel_to_cur_portal - position_rel_to_other_portal).length() < 1.0:
		return true
	else:
		return false

func _move_self_to_other_portal():
	var rel_to_cur_portal = _portal_tracking_us.global_transform.affine_inverse() * player.global_transform
	self.global_transform = _portal_tracking_us.other_portal.global_transform * rel_to_cur_portal


var _was_on_floor_last_frame = false
var _snapped_to_stairs_last_frame = false
func _snap_down_to_stairs_check():
	var did_snap = false
	if not player.is_on_floor() and player.velocity.y <= 0 and (_was_on_floor_last_frame or _snapped_to_stairs_last_frame) and $StairsBelowRayCast3D.is_colliding():
		var body_test_result = PhysicsTestMotionResult3D.new()
		var params = PhysicsTestMotionParameters3D.new()
		var max_step_down = -0.5
		params.from = self.global_transform
		params.motion = Vector3(0,max_step_down,0)
		if PhysicsServer3D.body_test_motion(player.get_rid(), params, body_test_result):
			var translate_y = body_test_result.get_travel().y
			self.position.y += translate_y
			player.apply_floor_snap()
			did_snap = true

	_was_on_floor_last_frame = player.is_on_floor()
	_snapped_to_stairs_last_frame = did_snap


@onready var _initial_separation_ray_dist_from_center# = ($StepUpSeparationRay_F.position * Vector3(1.0,0,1.0)).length()
var last_xz_vel : Vector3 = Vector3(0,0,0)
func _rotate_step_up_separation_ray():
	var xz_vel = player.velocity * Vector3(1,0,1)
	if xz_vel.length() < 0.1:
		xz_vel = last_xz_vel
	else:
		last_xz_vel = xz_vel
	var xz_ray_pos : Vector3 = xz_vel.normalized() * _initial_separation_ray_dist_from_center
	$StepUpSeparationRay_F.global_position.x = self.global_position.x + xz_ray_pos.x
	$StepUpSeparationRay_F.global_position.z = self.global_position.z + xz_ray_pos.z
	
	var xz_l_ray_pos = xz_ray_pos.rotated(Vector3(0,1.0,0), deg_to_rad(-50))
	$StepUpSeparationRay_L.global_position.x = self.global_position.x + xz_l_ray_pos.x
	$StepUpSeparationRay_L.global_position.z = self.global_position.z + xz_l_ray_pos.z
	
	var xz_r_ray_pos = xz_ray_pos.rotated(Vector3(0,1.0,0), deg_to_rad(50))
	$StepUpSeparationRay_R.global_position.x = self.global_position.x + xz_r_ray_pos.x
	$StepUpSeparationRay_R.global_position.z = self.global_position.z + xz_r_ray_pos.z
	
	# To prevent character from running up walls, we do a check for how steep
	# the slope in contact with our separation rays is
	$StepUpSeparationRay_F/RayCast3D.force_raycast_update()
	$StepUpSeparationRay_L/RayCast3D.force_raycast_update()
	$StepUpSeparationRay_R/RayCast3D.force_raycast_update()
	var max_slope_ang_dot = Vector3(0,1,0).rotated(Vector3(1.0,0,0), self.floor_max_angle).dot(Vector3(0,1,0))
	var any_too_steep = false
	if $StepUpSeparationRay_F/RayCast3D.is_colliding() and $StepUpSeparationRay_F/RayCast3D.get_collision_normal().dot(Vector3(0,1,0)) < max_slope_ang_dot:
		any_too_steep = true
	if $StepUpSeparationRay_L/RayCast3D.is_colliding() and $StepUpSeparationRay_L/RayCast3D.get_collision_normal().dot(Vector3(0,1,0)) < max_slope_ang_dot:
		any_too_steep = true
	if $StepUpSeparationRay_R/RayCast3D.is_colliding() and $StepUpSeparationRay_R/RayCast3D.get_collision_normal().dot(Vector3(0,1,0)) < max_slope_ang_dot:
		any_too_steep = true
	
	# Added blocked by wall check with ray to fix a glitch where you would jitter when running into
	# a wall next to a slope/stair. For some reason the Raycast3D hit from inside didn't work for this.
	$WallRayCast3D.target_position = $StepUpSeparationRay_F.position * Vector3(1,0,1)
	$WallRayCast3D.force_raycast_update()
	var f_blocked_by_wall = $WallRayCast3D.is_colliding()
	$WallRayCast3D.target_position = $StepUpSeparationRay_L.position * Vector3(1,0,1)
	$WallRayCast3D.force_raycast_update()
	var l_blocked_by_wall = $WallRayCast3D.is_colliding()
	$WallRayCast3D.target_position = $StepUpSeparationRay_R.position * Vector3(1,0,1)
	$WallRayCast3D.force_raycast_update()
	var r_blocked_by_wall = $WallRayCast3D.is_colliding()
	
	var should_disable = xz_vel.length() == 0 or any_too_steep
	$StepUpSeparationRay_F.disabled = should_disable or f_blocked_by_wall or (player.is_on_floor_only() and not $StepUpSeparationRay_F/RayCast3D.is_colliding())
	$StepUpSeparationRay_L.disabled = should_disable or l_blocked_by_wall or (player.is_on_floor_only() and not $StepUpSeparationRay_L/RayCast3D.is_colliding())
	$StepUpSeparationRay_R.disabled = should_disable or r_blocked_by_wall or (player.is_on_floor_only() and not $StepUpSeparationRay_R/RayCast3D.is_colliding())
	# It's necessary to disable the separation rays when on floor and not colliding
	# otherwise getting weird behavior for is_on_floor, it flickers between true and false
	# I made it is_on_floor_only since is_on_floor was causing other glitch when running into wall
	
	# There are still some slight glitches in edge cases but this one seems pretty stable
