extends CharacterBody2D
class_name CharacterProjectile

@export var speed: float
@export var pierce_amount: int = 1

var times_pierced: int = 0

func _ready() -> void:
	times_pierced = 0
	velocity = speed*Vector2.from_angle(rotation)
	
	if has_node(^"Hitbox"):
		var hitbox = get_node(^"Hitbox") as Hitbox
		if not hitbox.area_entered.is_connected(on_hit):
			hitbox.area_entered.connect(on_hit)

func _physics_process(delta: float) -> void:
	var collision = move_and_collide(velocity*delta)
	if collision: ObjectPool.return_object(self)

func on_hit(_area: Area2D) -> void:
	times_pierced += 1
	if times_pierced >= pierce_amount:
		ObjectPool.return_object(self)
