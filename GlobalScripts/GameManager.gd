extends Node3D

# ---------- VARIABLES ---------- #

var globalGravityScale = 1  # Increase and decrease to effect everyone's gravity. Incase wanting an area thats floaty.
var score = 0

# ---------- FUNCTIONS ---------- #

func _process(_delta):
	show_mouse_cursor()

# Making Cursor visible using "mouse_visible" key which is assigned in Project Settings > Input Map
func show_mouse_cursor():
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
	
	if Input.is_action_just_pressed("ui_focus_next"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# Fullscreen toggle
	if Input.is_action_just_pressed("fullscreen"):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)

func add_score():
	score += 1

func AddCheese(increment:int):
	# increment is the spot on the UI where it goes so you know which one youre missing.
	# 0 - 7 cheese slices each world
	pass
