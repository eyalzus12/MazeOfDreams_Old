extends NodeItem
class_name WeaponItem

func init_node() -> Node2D:
	var weapon := super.init_node()
	if not weapon is Weapon:
		Logger.error(str("item ", self, " is a weapon item but has a scene of a non weapon ", weapon))
	return weapon
