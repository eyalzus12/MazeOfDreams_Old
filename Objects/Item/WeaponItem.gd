extends NodeItem
class_name WeaponItem

@export_flags_2d_physics var weapon_layers: int
@export_flags_2d_physics var weapon_masks: int

func init_node() -> Node2D:
	var weapon := super.init_node()
	if not weapon is Weapon:
		push_error("item ", self, " is a weapon item but has a scene of a non weapon ", weapon)
	var wweapon := weapon as Weapon
	wweapon.weapon_layers = weapon_layers
	wweapon.weapon_masks = weapon_masks
	return wweapon
