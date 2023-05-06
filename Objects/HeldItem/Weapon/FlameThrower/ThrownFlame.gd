extends CharacterProjectile

const FIRE_EFFECT := preload("res://Objects/Effect/FireEffect/FireEffect.tscn")

@export var fire_interval: float
@export var fire_damage: float
@export var time_left: float

func _on_hit(area: Area2D) -> void:
	super._on_hit(area)
	if not area is Hurtbox: return
	var hurtbox: Hurtbox = area
	var hit_node: Node = hurtbox.hurtbox_owner
	if hit_node.has_method(&"apply_effect"):
		var fire_effect: Effect = ObjectPool.load_object(FIRE_EFFECT)
		fire_effect.fire_interval = fire_interval
		fire_effect.fire_damage = fire_damage
		fire_effect.time_left = time_left
		fire_effect.effect_owner = hit_node
		hit_node.apply_effect(fire_effect)
