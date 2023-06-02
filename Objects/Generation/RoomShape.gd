extends RigidBody2D
class_name RoomShape

@onready var collision: CollisionShape2D = $RoomShapeCollision

func get_room_size() -> float:
	if not collision.shape is RectangleShape2D:
		push_error("attempt to get room size of room with non rectangle shape")
		return NAN
	return collision.shape.size.x * collision.shape.size.y
