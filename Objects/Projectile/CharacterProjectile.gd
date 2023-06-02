extends CharacterBody2D
class_name CharacterProjectile

signal on_hit(area: Area2D)

var projectile_owner: Node:
	set(value):
		if not is_inside_tree():
			await ready
		projectile_owner = value
		
		if has_node(^"Hitbox"):
			var hitbox = get_node(^"Hitbox") as Hitbox
			if projectile_owner:
				if projectile_owner.has_meta("hitbox_layers"):
					hitbox.layers = projectile_owner.get_meta("hitbox_layers")
				if projectile_owner.has_meta("hitbox_masks"):
					hitbox.masks = projectile_owner.get_meta("hitbox_masks")
				hitbox.hitbox_owner = projectile_owner

@export var speed: float
@export var pierce_amount: int = 1

var times_pierced: int = 0

func _ready() -> void:
	times_pierced = 0
	velocity = speed*Vector2.from_angle(rotation)
	
	if has_node(^"Hitbox"):
		var hitbox = get_node(^"Hitbox") as Hitbox
		if not hitbox.area_entered.is_connected(_on_hit):
			hitbox.area_entered.connect(_on_hit)

func _physics_process(delta: float) -> void:
	var collision = move_and_collide(velocity*delta)
	if collision: ObjectPool.return_object(self)

func _on_hit(area: Area2D) -> void:
	on_hit.emit(area)
	times_pierced += 1
	if times_pierced >= pierce_amount:
		ObjectPool.return_object(self)
