extends CharacterBody2D

const SPEED := 700

func _ready() -> void:
	velocity = SPEED*Vector2.from_angle(rotation)

func _physics_process(delta: float) -> void:
	var collision = move_and_collide(velocity*delta)
	if collision: queue_free()

func _on_hitbox_area_entered(_area: Area2D) -> void:
	queue_free()
