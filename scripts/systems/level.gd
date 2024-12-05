class_name Level
extends Node3D


@export var player: PlayerCharacter
@export var user_interface: UserInterface
@export var camera_controller: CameraController
@export var lock_on_system: LockOnSystem
@export var backstab_system: BackstabSystem
@export var dizzy_system: DizzySystem
@export var checkpoint_system: CheckpointSystem
@export var music_system: MusicSystem
@export var void_death_system: VoidDeathSystem


func _enter_tree():
	GlobalReferences.backstab_system = backstab_system
	GlobalReferences.dizzy_system = dizzy_system
	GlobalReferences.lock_on_system = lock_on_system
	GlobalReferences.camera_controller = camera_controller
	GlobalReferences.player = player
	GlobalReferences.user_interface = user_interface
	GlobalReferences.checkpoint_system = checkpoint_system
	GlobalReferences.music_system = music_system
	GlobalReferences.void_death_system = void_death_system
