extends Area2D
class_name Hitbox

@export var damage: float
@export var stun: float
@export var pushback: float

@export var active: bool:
	set(value):
		active = value
		if not is_inside_tree():
			await ready
		for node in get_children():
			if node is CollisionShape2D:
				node.set_deferred(&"disabled", not active)

