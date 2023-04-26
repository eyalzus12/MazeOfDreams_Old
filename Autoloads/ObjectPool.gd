extends Node

const DEFAULT_INITIAL_LOAD_AMOUNT := 4
const DEFAUT_ADDITIONAL_LOAD_AMOUNT := 2

#PackedScene to Array[Node]
var pool: Dictionary = {}
#PackedScene to Dictionary[Node,_]
var pool_set: Dictionary = {}

#PackedScene to Array[Node]
var return_queue: Dictionary = {}
#PackedScene to Dictionary[Node,_]
var return_queue_set: Dictionary = {}

var pooled_object_amount := 0

func _process(_delta: float) -> void:
	full_handle_return_queue()

func load_object(
		object: PackedScene,
		additional_load_override = DEFAUT_ADDITIONAL_LOAD_AMOUNT,
		initial_load_override = DEFAULT_INITIAL_LOAD_AMOUNT
	) -> Node:
	
	#no pool
	if not object in pool:
		pool_load_object(object, initial_load_override)
	#pool empty
	elif pool[object].size() < 1:
		pool_load_object(object, additional_load_override)
	
	var pooled_object: Node = pool[object].pop_back()
	pool_set[object].erase(pooled_object)
	
	pooled_object_amount -= 1
	pooled_object.set_meta(&"origin_object", object)
	pooled_object.request_ready()
	return pooled_object

func return_object(pooled_object: Node) -> void:
	var object: PackedScene
	if not pooled_object.has_meta(&"origin_object"):
		#not origin metadata. try to figure out from property.
		var possible_origin = pooled_object.scene_file_path
		#no info, or bad path
		if possible_origin == "" or not ResourceLoader.exists(possible_origin):
			push_warning(
				"trying to return ",
				pooled_object,
				" to pool, but it has no origin_object metadata to indicate where to put it.",
				" additionally, its scene_file_path is empty or invalid.",
				" this could be caused by the object not being created at the pool.",
				" it will simply be disposed."
				)
			pooled_object.queue_free()
			return
		#found origin. set metadata.
		object = load(possible_origin)
		pooled_object.set_meta(&"origin_object", object)
	else:
		object = pooled_object.get_meta(&"origin_object", null)
	
	if not object in return_queue:
		return_queue[object] = []
		return_queue_set[object] = {}
	
	if pooled_object in return_queue_set[object]:
		return
	
	return_queue[object].push_back(pooled_object)
	return_queue_set[object][pooled_object] = null

#load a requested amount of new instances
func pool_load_object(object: PackedScene, amount: int) -> void:
	if not object in pool:
		pool[object] = []
		pool_set[object] = {}
	for _i in range(amount):
		var pooled_object = object.instantiate()
		pool[object].push_back(pooled_object)
		pool_set[object][pooled_object] = null
		pooled_object_amount += 1

func full_handle_return_queue() -> void:
	for object in return_queue.keys():
		handle_return_queue(object)

func handle_return_queue(object: PackedScene) -> void:
	if not object in return_queue: return
	var pooled_object_array: Array = return_queue[object]
	while pooled_object_array.size() > 0:
		var pooled_object = pooled_object_array.pop_back()
		return_queue_set[object].erase(pooled_object)
		
		if is_instance_valid(pooled_object.get_parent()):
			pooled_object.get_parent().remove_child(pooled_object)
		
		if not object in pool:
			pool[object] = []
			pool_set[object] = {}
		
		pool[object].push_back(pooled_object)
		pool_set[object][pooled_object] = null
		
		pooled_object_amount += 1

func _exit_tree() -> void:
	full_clean_pool()

func full_clean_pool() -> void:
	for object in pool.keys():
		clean_pool(object)

func clean_pool(object: PackedScene) -> void:
	if not object in pool: return
	var pooled_object_array: Array = pool[object]
	while pooled_object_array.size() > 0:
		var pooled_object = pooled_object_array.pop_back()
		pool_set[object].erase(pooled_object)
		
		pooled_object.queue_free()
		pooled_object_amount -= 1
