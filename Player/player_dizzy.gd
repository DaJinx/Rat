class_name PlayerDizzyState
extends PlayerStateMachine

@export var dizzy_length: float = 3.0

@export var attack_state: PlayerAttackState
@export var block_state: PlayerBlockState
@export var parry_state: PlayerParryState

@export var dizzy_stars: DizzyStars

@export var hit_sfx: AudioStreamPlayer3D
@export var dizzy_hit_sfx: AudioStreamPlayer3D
@export var dizzy_sfx: AudioStreamPlayer

var _timer: Timer

var _dizzy_sfx_tween: Tween
var _default_dizzy_sfx_volume: float

var _skip_damage: bool = false


func _ready():
	Player = $"../.."
	
	#super._ready()
	
	#Player.instability_component.full_instability.connect(
		#func():
			#if not parent_state.current_state is PlayerDeathState and \
			#parent_state.current_state != self:
				#parent_state.change_state(self)
	#)
	
	#Player.hitbox_component.damage_source_hit.connect(
		#func(incoming_damage_source: DamageSource):
			#if parent_state.current_state != self: return
			#Player.locomotion_component.knockback(
				#incoming_damage_source.damage_attributes.knockback,
				#incoming_damage_source.entity.global_position
			#)
			#Player.character.hit_and_death_animations.hit()
			#hit_sfx.play()
			#if _skip_damage:
				#_skip_damage = false
				#return
			#Player.health_component.incoming_damage(incoming_damage_source)
	#)
	
	_timer = Timer.new()
	_timer.wait_time = dizzy_length
	_timer.autostart = false
	_timer.one_shot = true
	_timer.timeout.connect(
		func(): parent_state.transition_to_default_state()
	)
	add_child(_timer)
	
	#dizzy_stars.enabled = false
	#_default_dizzy_sfx_volume = dizzy_sfx.volume_db


func enter() -> void:
	Player.melee_component.interrupt_attack()
	Player.rotation_component.can_rotate = false
	Player.locomotion_component.set_active_strategy("root_motion")
	Player.character.dizzy_victim_animations.dizzy_from_parry()
	
	GlobalReferences.user_interface.hud.instability_bar.play_max_instability()
	
	_skip_damage = false
	if parent_state.previous_state is PlayerBlockState:
		_skip_damage = true
	
	dizzy_stars.enabled = true
	
	dizzy_hit_sfx.play()
	if _dizzy_sfx_tween: _dizzy_sfx_tween.kill()
	dizzy_sfx.volume_db = _default_dizzy_sfx_volume
	dizzy_sfx.play()
	
	_timer.start()


func process_player() -> void:
	Player.set_rotation_target_to_lock_on_target()


func process_movement_animations() -> void:
	Player.character.idle_animations.active = Player.lock_on_target != null
	Player.character.movement_animations.dir = Vector3.ZERO


func exit() -> void:
	Player.rotation_component.can_rotate = true
	Player.locomotion_component.set_active_strategy("programmatic")
	Player.character.dizzy_victim_animations.disable_blend_dizzy()
	Player.instability_component.come_out_of_full_instability(0)
	
	GlobalReferences.user_interface.hud.instability_bar.reset()
	GlobalReferences.user_interface.hud.instability_bar.hide_bar()
	
	dizzy_stars.enabled = false
	_dizzy_sfx_tween = create_tween()
	_dizzy_sfx_tween.tween_property(
		dizzy_sfx, "volume_db",
		-80, 0.5 )
	
	_timer.stop()
