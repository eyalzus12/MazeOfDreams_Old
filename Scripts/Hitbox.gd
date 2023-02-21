extends Area2D
class_name Hitbox

onready var shape: CollisionShape2D = $HitboxShape

export var damage: float
export var stun: float
export var pushback: float

export var active: bool setget set_active

func _ready() -> void:
	set_active(active)

func set_active(b: bool) -> void:
	active = b
	if is_inside_tree(): shape.set_deferred("disabled", not b)
