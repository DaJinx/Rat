extends Node2D

@onready var Game_1_Level_1: Node2D = $Game_1/TestLevel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func PlayerEntered():
	Game_1_Level_1.visible = true
	var player = Game_1_Level_1.get_node("Player2D")
	player.controlled = true
	
	# Makes the pixel art look crisp instead of blurry.
	get_viewport().canvas_item_default_texture_filter = \
	Viewport.DefaultCanvasItemTextureFilter.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST

func PlayerExit():
	get_viewport().canvas_item_default_texture_filter = \
	Viewport.DefaultCanvasItemTextureFilter.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_LINEAR
