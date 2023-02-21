extends Area2D
class_name Hurtbox

onready var shape: CollisionShape2D = $HurtboxShape

export var active: bool setget set_active

func _ready() -> void:
	set_active(active)

func set_active(b: bool) -> void:
	active = b
	if is_inside_tree(): shape.set_deferred("disabled", not b)
