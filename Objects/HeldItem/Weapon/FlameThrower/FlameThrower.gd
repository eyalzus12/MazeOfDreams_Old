extends Weapon

const THROWN_FLAME := preload("res://Objects/HeldItem/Weapon/FlameThrower/ThrownFlame.tscn")

@onready var shoot_location := $Base/ShootLocationMarker

@export var fire_interval: float
@export var fire_damage: float
@export var time_left: float

func throw() -> void:
	var flame: CharacterProjectile = ObjectPool.load_object(THROWN_FLAME)
	flame.fire_interval = fire_interval
	flame.fire_damage = fire_damage
	flame.time_left = time_left
	flame.projectile_owner = weapon_owner
	flame.global_position = shoot_location.global_position
	flame.global_rotation = self.global_rotation
	#make your projectiles count as hitting
	if not flame.on_hit.is_connected(on_hit):
		flame.on_hit.connect(on_hit)
	#put projectile
	get_tree().root.add_child(flame)
