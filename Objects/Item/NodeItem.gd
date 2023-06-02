extends Item
class_name NodeItem

@export var scene: PackedScene

func init_node() -> Node2D:
	#we load 1 extra when we need, and 3 at the start
	#we load 3 to handle cases where the item is removed too quickly
	#and the return queue has no time to be processed
	var node := ObjectPool.load_object(scene,1,3)
	for info in extra_info:
		node.set(info,extra_info[info])
	for info in meta_info:
		node.set_meta(info,meta_info[info])
	return node
