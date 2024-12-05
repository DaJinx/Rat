extends Node3D

@onready var RopePiece = preload("res://Objects/Ropes/RopePiece.tscn")
var pieceLength :float = 0.5
var ropeParts := []
@onready var endOne := $End_1
@onready var endTwo := $End_2
var ropeCloseTolerance :float = 0.01


func _ready() -> void:
	# Gets the location of their joint.
	var startPos = endOne.get_node("Collision/Joint").global_position
	var endPos = endTwo.get_node("Collision/Joint").global_position
	
	var distance = startPos.distance_to(endPos)
	var segmentAmount = round(distance / pieceLength)
	
	CreateRope(segmentAmount, endOne, endPos)


func CreateRope(piecesAmount:int, parent:Object, endPos:Vector3) -> void:
	for i in piecesAmount:
		# Add a new piece in front, then set that as the new parent for the next piece and to change settings.
		parent = AddPiece(parent, i)
		parent.set_name("rope_piece_"+str(i))
		ropeParts.append(parent)
		
		var jointPos = parent.get_node("Collision/Joint").global_position
		if jointPos.distance_to(endPos) < ropeCloseTolerance:
			break
	
	# Locks the end in place so it doesnt hang down.
	#endTwo.get_node("Collision/Joint").node_a = endTwo.get_path()
	#endTwo.get_node("Collision/Joint").node_b = ropeParts[-1].geth_path()


func AddPiece(parent:Object, id:int) -> Object:
	# Set up
	var joint:PinJoint3D = parent.get_node("Collision/Joint") as PinJoint3D
	var piece:Object = RopePiece.instantiate() as Object
	add_child(piece)
	
	# Change settings
	piece.global_position = joint.global_position
	#piece.rotation = piece.rotate_to(endTwo.position)
	piece.parent = self
	piece.id = id
	
	# Attach the two for simulation
	joint.node_a = parent.get_path()
	joint.node_b = piece.get_path()
	
	return piece
