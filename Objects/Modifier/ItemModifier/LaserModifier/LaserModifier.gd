extends Modifier

const LASER := preload("res://Objects/Modifier/ItemModifier/LaserModifier/Laser.tscn")

func attack_started() -> void:
	if not is_inside_tree(): return
	if not is_instance_valid(entity): return
	var laser: CharacterBody2D = ObjectPool.load_object(LASER)
	laser.position = entity.position
	laser.rotation = entity.direction.angle()
	get_tree().root.add_child(laser)
