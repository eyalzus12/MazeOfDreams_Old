extends Area2D
class_name Hitbox

@export var damage: float
@export var stun: float
@export var pushback: float
@export var is_projectile: bool = false

@export var hitbox_layers: Array[String]:
	set(value):
		hitbox_layers = value
		collision_layer = 0
		for layer in hitbox_layers:
			set_collision_layer_value(Globals.PHYSICS_LAYERS["hitbox_"+layer],1)

var layers: Array:
	set(value):
		var temp: Array[String] = []
		temp.assign(value)
		hitbox_layers = temp

@export var hitbox_masks: Array[String]:
	set(value):
		hitbox_masks = value
		collision_mask = 0
		for mask in hitbox_masks:
			set_collision_mask_value(Globals.PHYSICS_LAYERS["hurtbox_"+mask],1)

var masks: Array:
	set(value):
		var temp: Array[String] = []
		temp.assign(value)
		hitbox_masks = temp


@export var active: bool:
	set(value):
		active = value
		if not is_inside_tree():
			await ready
		for node in get_children():
			if node is CollisionShape2D:
				node.set_deferred(&"disabled", not active)

@export var hitbox_owner: Node
