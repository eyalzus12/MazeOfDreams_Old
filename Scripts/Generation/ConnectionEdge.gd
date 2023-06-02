extends Resource
class_name ConnectionEdge

var room1: RoomShape
var room2: RoomShape

func _init(room1_: RoomShape, room2_: RoomShape) -> void:
	super()
	room1 = room1_
	room2 = room2_

func get_weight() -> float:
	return \
		abs(room1.global_position.x - room2.global_position.x) + \
		abs(room1.global_position.y - room2.global_position.y)
