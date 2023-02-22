extends Area2D
class_name Hitbox

export var damage: float
export var stun: float
export var pushback: float

export var active: bool setget set_active

func _ready() -> void:
	set_active(active)

func set_active(b: bool) -> void:
	active = b
	if is_inside_tree():
		for node in get_children():
			if node is CollisionShape2D:
				node.set_deferred("disabled", not b)
