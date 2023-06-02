extends Area2D
class_name Hurtbox

@export var hurtbox_layers: Array[String]:
	set(value):
		hurtbox_layers = value
		collision_layer = 0
		for layer in hurtbox_layers:
			set_collision_layer_value(Globals.PHYSICS_LAYERS["hurtbox_"+layer],1)

var layers: Array:
	set(value):
		var temp: Array[String] = []
		temp.assign(value)
		hurtbox_layers = temp

@export var hurtbox_masks: Array[String]:
	set(value):
		hurtbox_masks = value
		collision_mask = 0
		for mask in hurtbox_masks:
			set_collision_mask_value(Globals.PHYSICS_LAYERS["hitbox_"+mask],1)

var masks: Array:
	set(value):
		var temp: Array[String] = []
		temp.assign(value)
		hurtbox_masks = temp

@export var active: bool :
	set(value):
		active = value
		if not is_inside_tree():
			await ready
		for node in get_children():
			if node is CollisionShape2D:
				node.set_deferred(&"disabled", not active)

@export var hurtbox_owner: Node
