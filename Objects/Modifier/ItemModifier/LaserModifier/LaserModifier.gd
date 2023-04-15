extends ItemModifier

const LASER := preload("res://Objects/Modifier/ItemModifier/LaserModifier/Laser.tscn")

func attack_start() -> void:
	if not is_instance_valid(entity): return
	var laser := LASER.instantiate()
	laser.position = entity.position
	laser.rotation = entity.direction.angle()
	get_tree().root.add_child(laser)
