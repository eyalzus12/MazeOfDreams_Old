extends Weapon

const FINGER_NAIL := preload("res://Objects/HeldItem/Weapon/FingerNailGun/FingerNail.tscn")

@onready var shoot_location := $Base/ShootLocationMarker

func shoot() -> void:
	for i in [-1/2.0,-1/4.0,0,1/4.0,1/2.0]:
		#load projectile
		var finger_nail: CharacterProjectile = ObjectPool.load_object(FINGER_NAIL,10,15)
		finger_nail.projectile_owner = weapon_owner
		finger_nail.global_position = shoot_location.global_position
		finger_nail.global_rotation = self.global_rotation + i
		#make your projectiles count as hitting
		if not finger_nail.on_hit.is_connected(on_hit):
			finger_nail.on_hit.connect(on_hit)
		#put projectile
		get_tree().root.add_child(finger_nail)
