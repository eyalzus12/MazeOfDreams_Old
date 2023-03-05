extends Area2D
class_name Hurtbox

@export var active: bool : set = set_active

func _ready() -> void:
	set_active(active)

func set_active(b: bool) -> void:
	active = b
	if is_inside_tree():
		for node in get_children():
			if node is CollisionShape2D:
				node.set_deferred(&"disabled", not b)
