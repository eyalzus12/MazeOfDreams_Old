extends Modifier

const LASER := preload("res://Objects/Modifier/ItemModifier/LaserModifier/Laser.tscn")

func attack_started() -> void:
	if not is_inside_tree(): return
	if not is_instance_valid(modifier_owner): return
	var laser: CharacterProjectile = ObjectPool.load_object(LASER)
	laser.projectile_owner = modifier_owner
	laser.position = modifier_owner.position
	laser.rotation = modifier_owner.direction.angle()
	
	if modifier_owner.has_method("attack_hit"):
		if not laser.on_hit.is_connected(modifier_owner.attack_hit):
			laser.on_hit.connect(modifier_owner.attack_hit)
	
	get_tree().root.add_child(laser)
