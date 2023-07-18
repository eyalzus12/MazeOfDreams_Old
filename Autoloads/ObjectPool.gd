extends Node

const UPDATE_POOL_COUNTERS := true
const DEFAULT_INITIAL_LOAD_AMOUNT := 4
const DEFAUT_ADDITIONAL_LOAD_AMOUNT := 2

#PackedScene to Array[Node]
var pool: Dictionary = {}
#PackedScene to Dictionary[Node,_]
var pool_set: Dictionary = {}
#PackedScene to int
var pool_fill_counter: Dictionary = {}
#PackedScene to int
var pool_load_counter: Dictionary = {}

#PackedScene to Array[Node]
var return_queue: Dictionary = {}
#PackedScene to Dictionary[Node,_]
var return_queue_set: Dictionary = {}

var pooled_object_amount := 0

func _ready() -> void:
	Globals.game_closed.connect(_exit_tree)

func _process(_delta: float) -> void:
	full_handle_return_queue()

#NOTE: certain objects, like rigid bodies, don't reset all of their properties in _ready
#put that explicit reset logic in pool_setup
#some objects, like rigid bodies, may need some more coding to properly reset them
func load_object(
		object: PackedScene,
		additional_load_override = DEFAUT_ADDITIONAL_LOAD_AMOUNT,
		initial_load_override = DEFAULT_INITIAL_LOAD_AMOUNT
	) -> Node:
	
	#no pool
	if not object in pool:
		pool_load_object(object, initial_load_override)
	#pool empty
	elif pool[object].is_empty():
		pool_load_object(object, additional_load_override)
	
	var pooled_object: Node = pool[object].pop_back()
	pool_set[object].erase(pooled_object)
	
	pooled_object_amount -= 1
	pooled_object.set_meta(&"origin_object", object)
	
	if pooled_object.has_method(&"pool_setup"):
		pooled_object.pool_setup()
		
	pooled_object.request_ready()
	return pooled_object

func return_object(pooled_object: Node) -> void:
	var object: PackedScene
	if not pooled_object.has_meta(&"origin_object"):
		#not origin metadata. try to figure out from property.
		var possible_origin = pooled_object.scene_file_path
		#no info, or bad path
		if possible_origin == "" or not ResourceLoader.exists(possible_origin):
			Logger.warn(str(
				"trying to return ",
				pooled_object,
				" to pool, but it has no origin_object metadata to indicate where to put it.",
				" additionally, its scene_file_path is empty or invalid.",
				" this could be caused by the object not being created from a scene or at the pool.",
				" it will simply be disposed."
				))
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
	
	if pooled_object.has_method(&"pool_cleanup"):
		pooled_object.pool_cleanup()
	return_queue[object].push_back(pooled_object)
	return_queue_set[object][pooled_object] = null

#load objects such that there are at least amount of them
func pool_load_object_upto(object: PackedScene, amount: int) -> void:
	if not object in pool:
		pool_load_object(object, amount)
		return
	var currently_pooled: int = pool[object].size()
	if currently_pooled >= amount:
		return
	var need_to_load: int = amount - currently_pooled
	pool_load_object(object, need_to_load)

#load a requested amount of new instances
func pool_load_object(object: PackedScene, amount: int) -> void:
	if not object in pool:
		pool[object] = []
		pool_set[object] = {}
		pool_fill_counter[object] = 0
		pool_load_counter[object] = 0
	for _i in range(amount):
		var pooled_object = object.instantiate()
		pool[object].push_back(pooled_object)
		pool_set[object][pooled_object] = null
	pooled_object_amount += amount
	pool_load_counter[object] += amount
	pool_fill_counter[object] += 1

func full_handle_return_queue() -> void:
	for object in return_queue.keys():
		handle_return_queue(object)

func handle_return_queue(object: PackedScene) -> void:
	if not object in return_queue: return
	var pooled_object_array: Array = return_queue[object]
	pooled_object_amount += pooled_object_array.size()
	while pooled_object_array.size() > 0:
		var pooled_object = pooled_object_array.pop_back()
		return_queue_set[object].erase(pooled_object)
		
		var parent = pooled_object.get_parent()
		if is_instance_valid(parent):
			parent.remove_child(pooled_object)
		
		if not object in pool:
			pool[object] = []
			pool_set[object] = {}
		
		pool[object].push_back(pooled_object)
		pool_set[object][pooled_object] = null

func _exit_tree() -> void:
	full_handle_return_queue()
	if OS.is_debug_build():
		print_pool_counters()
	full_clean_pool()

func print_pool_counters() -> void:
	Logger.info("how many times each scene needed a pool fillup:")
	for scene in pool_fill_counter.keys():
		Logger.info(str(pool_fill_counter[scene], " - ", scene.resource_path))
	Logger.info("how many times new instances were created:")
	for scene in pool_load_counter.keys():
		Logger.info(str(pool_load_counter[scene], " - ", scene.resource_path))

func full_clean_pool() -> void:
	for object in pool.keys():
		clean_pool(object)

func clean_pool(object: PackedScene) -> void:
	if not object in pool: return
	var pooled_object_array: Array = pool[object]
	pooled_object_amount -= pooled_object_array.size()
	while pooled_object_array.size() > 0:
		var pooled_object = pooled_object_array.pop_back()
		pool_set[object].erase(pooled_object)
		
		pooled_object.queue_free()
