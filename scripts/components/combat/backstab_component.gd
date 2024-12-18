class_name BackstabComponent
extends Node3D


@export var debug: bool = false
@export var enabled: bool = true
@export var entity: CharacterBody3D
@export var attachment_point: Node3D
@export var health_component: HealthComponent
# used by backstab system to check state
@export var notice_component: NoticeComponent
@export var crosshair: Crosshair
@export var puncture_sound: AudioStreamPlayer3D

var _dist_to_player: float = 0.0
var _angle_to_player: float = 0.0
var _angle_to_entity: float = 0.0

@onready var _player: PlayerCharacter = GlobalReferences.player
@onready var _backstab_system: BackstabSystem = GlobalReferences.backstab_system


func _ready():
	if crosshair: crosshair.register_callback(
		func():
			return _backstab_system.backstab_victim != null and \
			_backstab_system.backstab_victim == self
	)


func _process(_delta):
	if not enabled:
		return
		
	global_position = attachment_point.global_position
	_dist_to_player = entity.global_position.distance_to(_player.global_position)
	_angle_to_player = rad_to_deg(
		Vector3.FORWARD.rotated(Vector3.UP, entity.global_rotation.y).angle_to(
			entity.global_position.direction_to(_player.global_position)
		)
	)
	_angle_to_entity = rad_to_deg(
			Vector3.FORWARD.rotated(Vector3.UP, _player.global_rotation.y).angle_to(
				_player.global_position.direction_to(entity.global_position)
		)
	)
	if (
		_dist_to_player < 1.5 and \
		_angle_to_player > 125 and \
		_angle_to_entity < 80
	):
		_backstab_system.set_backstab_victim(self, _dist_to_player)
	else:
		_backstab_system.clear_backstab_victim(self)


func process_hit() -> void:
	if _backstab_system.backstab_victim != self:
		return
	puncture_sound.play()
	health_component.deal_max_damage = true
	entity.rotation.y = _player.rotation.y
