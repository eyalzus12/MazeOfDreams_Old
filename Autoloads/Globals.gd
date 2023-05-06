extends Node2D

const SMALL_WAIT_TIME: float = 0.01
const DROPPED_ITEM: PackedScene = preload("res://Objects/DroppedItem/DroppedItem.tscn")
const DAMAGE_POPUP := preload("res://Objects/UI/DamagePopup/DamagePopup.tscn")
const DISABLE_ENEMIES: bool = false

var dragged_item: Item:
	set(value):
		if not is_inside_tree():
			await ready
		dragged_item = value
		queue_redraw()
var dragged_item_inventory: Inventory
var dragged_item_slot: InventorySlot
var dragged_item_owner: Node2D

func reset_item() -> void:
	dragged_item = null
	dragged_item_inventory = null
	dragged_item_slot = null
	dragged_item_owner = null

var drop_input_handled: bool = false

#set of inventories
var inventories: Dictionary
#set of inventories
var open_inventories: Dictionary

var old_window_mode: DisplayServer.WindowMode

var god: bool = false

func _process(_delta: float) -> void:
	if dragged_item:
		queue_redraw()
	if Input.is_action_just_pressed(&"toggle_god"):
		god = not god
		print("god" if god else "not god")
	if Input.is_action_just_pressed(&"close_game"):
		get_tree().quit()
	if Input.is_action_just_pressed(&"toggle_fullscreen"):
		match DisplayServer.window_get_mode():
			DisplayServer.WINDOW_MODE_FULLSCREEN:
				DisplayServer.window_set_mode(old_window_mode)
				old_window_mode = DisplayServer.WINDOW_MODE_MAXIMIZED
			_:
				old_window_mode = DisplayServer.window_get_mode()
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func _unhandled_input(event: InputEvent) -> void:
	if dragged_item and event.is_action(&"player_interact") and event.is_pressed():
		await temp_signal(self, SMALL_WAIT_TIME)
		if drop_input_handled:
			drop_input_handled = false
			return
		drop_item(dragged_item, get_global_mouse_position())
		reset_item()

#call this function to return the dragged item to any fitting inventory
#this should preferably be called by inventories that are explicitly rejecting the item
#like when closing the inventory and holding something from the modifier inventory
func return_dragged_item() -> void:
	if not is_instance_valid(dragged_item): return
	
	for inventory_ in inventories:
		var inventory: Inventory = inventory_
		if not inventory.pickup_target: continue
		var inserted: bool = inventory.try_insert(dragged_item)
		if inserted:
			reset_item()
			return
	#if we got here, the item couldn't find an inventory to get dropped to
	#so we drop it on the ground
	drop_item(dragged_item, dragged_item_owner.global_position)

func drop_item(item: Item, pos: Vector2) -> void:
	var dropped_item: DroppedItem = ObjectPool.load_object(DROPPED_ITEM)
	dropped_item.item = item
	dropped_item.global_position = pos
	get_tree().root.add_child(dropped_item)
	
	dropped_item.pickup_area.input_pickable = false
	schedule_property_change(dropped_item.pickup_area,&"input_pickable",true)

func temp_timer(time: float = SMALL_WAIT_TIME) -> Timer:
	var timer := Timer.new()
	timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
	timer.wait_time = time
	timer.autostart = true
	timer.one_shot = true
	timer.timeout.connect(timer.queue_free)
	return timer

func add_temp_timer(node: Node, time: float = SMALL_WAIT_TIME) -> Timer:
	var timer := temp_timer(time)
	node.add_child(timer)
	return timer

func temp_signal(node: Node, time: float = SMALL_WAIT_TIME) -> Signal:
	return add_temp_timer(node, time).timeout

func schedule_action(node: Node, action: Callable, time: float = SMALL_WAIT_TIME) -> void:
	add_temp_timer(node, time).timeout.connect(action)

func schedule_property_change(node: Node, property: StringName, value: Variant, time: float = SMALL_WAIT_TIME) -> void:
	schedule_action(node, node.set.bind(property,value), time)

func _draw() -> void:
	if not dragged_item: return
	var mouse_pos := get_local_mouse_position()
	var center_offset := dragged_item.texture.get_size()/2
	draw_texture(dragged_item.texture, mouse_pos-center_offset)
