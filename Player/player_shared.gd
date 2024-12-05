extends Node

## This is the variables all the player scripts reference from. But the node isnt physically used.
## Just a quick button to open the script.
## So DO NOT set any of these values in game expecting it to change for them all.

@onready var Player: PlayerCharacter = $".."
@onready var Inputs: PlayerInputs = %"Inputs"
@onready var Movement: Node = %"Movement"
@onready var Combat: Node = %"Combat"
@onready var Health: Node = %"Health"
@onready var StateMachine: Node = %"StateMachine"
@onready var sPortal: Node = $"../Portal"
@onready var Camera: Node3D = $"../CameraRoot"
@onready var EnemyDetection: Area3D = $"../EnemyDetection"

@onready var mesh: Node3D = $"../Character"

@onready var AudioPlayer: AudioStreamPlayer3D = $"../AudioPlayers/AudioPlayer"
@onready var coin_collecting: AudioStreamPlayer3D = $"../AudioPlayers/CoinCollecting"
@onready var footsteps: AudioStreamPlayer3D = $"../AudioPlayers/Footsteps"
@onready var animation: AnimationPlayer = $"../Character/AnimationPlayer"
