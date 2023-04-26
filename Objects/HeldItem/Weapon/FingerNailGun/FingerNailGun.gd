extends Weapon

const FINGER_NAIL := preload("res://Objects/HeldItem/Weapon/FingerNailGun/FingerNail.tscn")

@onready var shoot_location := $Base/ShootLocationMarker

func shoot() -> void:
	for i in [-1/2.0,-1/4.0,0,1/4.0,1/2.0]:
		var finger_nail := ObjectPool.load_object(FINGER_NAIL,10,15)
		finger_nail.global_position = shoot_location.global_position
		finger_nail.global_rotation = self.global_rotation + i
		get_tree().root.add_child(finger_nail)
