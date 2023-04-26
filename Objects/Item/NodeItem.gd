extends Item
class_name NodeItem

@export var scene: PackedScene

func init_node() -> Node2D:
	var node := scene.instantiate()
	for info in extra_info:
		node.set_meta(info,extra_info[info])
	return node
