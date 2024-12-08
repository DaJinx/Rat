class_name Hud
extends Control

# ---------- VARIABLES ---------- #

@onready var coinsLabel = $UserInterface/CoinsLabel
@onready var controllerDisplay = $UserInterface/SubViewportContainer
@onready var controllerDisplay_SubView = $UserInterface/SubViewportContainer/SubViewport
var usesControllerDisplay = false
var controllerDisplayTransparency:float = 0.85
@onready var info_box: Label = $UserInterface/InfoBox

var lastInput

# ---------- FUNCTIONS ---------- #

func _ready() -> void:
	SetControllerDisplay()

func _process(_delta):
	coinsLabel.text = "x %d" % GameManager.score # Set the coin label text to the score variable
	
	info_box.text = "Controller Type:   " + str( Input.get_joy_name(0) ) + "
	Last Input:   " + str( lastInput ) + "
	FPS:    " + str( Engine.get_frames_per_second() )

func SetControllerDisplay():
	if !controllerDisplay:
		return
	
	if usesControllerDisplay:
		controllerDisplay.visible = true
		
		# Sets the transparency of the UI element.
		controllerDisplay.modulate.a = controllerDisplayTransparency
		
		#controllerDisplay_SubView.debug_draw = Viewport.DEBUG_DRAW_NORMAL_BUFFER
		controllerDisplay_SubView.debug_draw = 0
		# 0 = Default
		# 1 = Unshaded
		# 2 = Lighting Only
		# 5 = Normal Effect
	
	else:
		controllerDisplay.visible = false

func FadeOut():
	var animation = $UserInterface/TransitionFade/AnimationPlayer
	animation.play("fade_to_black")
	await get_tree().create_timer(0.5).timeout # Enough for animation to finish
	#await get_tree().create_timer(0.5).timeout # Extra wait
	animation.play("fade_to_clear")

func _input(event):
	lastInput = event
