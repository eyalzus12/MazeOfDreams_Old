extends Resource
class_name HallwaySegment

var pos1: Vector2
var pos2: Vector2

func _init(pos1_: Vector2, pos2_: Vector2) -> void:
	super()
	pos1 = pos1_
	pos2 = pos2_
