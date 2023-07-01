extends Node2D

const DROPPED_ITEM := preload("res://Objects/DroppedItem/DroppedItem.tscn")
const MAX_ITEM_COUNT := 1000

func _ready() -> void:
	z_index = RenderingServer.CANVAS_ITEM_Z_MAX

#set of inventories
var inventories: Dictionary
#set of inventories
var open_inventories: Dictionary

var dragged_item: InventoryItem:
	set(value):
		if not is_inside_tree():
			await ready
		dragged_item = value
		if value == null:
			reset_item()
		queue_redraw()
var dragged_item_inventory: Inventory
var dragged_item_slot: InventorySlot
var dragged_item_owner: Node2D

func reset_item() -> void:
	# the ifs here prevent an infinite loop from reset_item calls inside set functions
	if dragged_item:
		dragged_item = null
	if dragged_item_inventory:
		dragged_item_inventory = null
	if dragged_item_slot:
		dragged_item_slot = null
	if dragged_item_owner:
		dragged_item_owner = null

var drop_input_handled: bool = false

func _process(_delta: float) -> void:
	if dragged_item:
		queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if dragged_item and event.is_action(&"player_interact") and event.is_pressed():
		wait_and_drop_item()

func wait_and_drop_item() -> void:
	await Globals.temp_signal()
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
		var item_left: InventoryItem = inventory.try_insert(dragged_item)
		dragged_item = item_left
		if not item_left:
			return
	#if we got here, the item couldn't find an inventory to get dropped to
	#so we drop it on the ground
	drop_item(dragged_item, dragged_item_owner.global_position)
	reset_item()

func drop_item(item: InventoryItem, pos: Vector2) -> void:
	for i in range(item.count):
		var dropped_item: DroppedItem = ObjectPool.load_object(DROPPED_ITEM)
		dropped_item.item = item.item
		dropped_item.global_position = pos
		get_tree().root.add_child(dropped_item)
		
		dropped_item.pickup_area.input_pickable = false
		Globals.schedule_property_change(dropped_item.pickup_area, &"input_pickable", true)

func _draw() -> void:
	if not dragged_item or not dragged_item.item: return
	var mouse_pos := get_local_mouse_position()
	var center_offset := dragged_item.item.texture.get_size()/2
	dragged_item.draw(self, mouse_pos-center_offset)
