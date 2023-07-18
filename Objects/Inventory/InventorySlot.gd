extends Button
class_name InventorySlot

signal item_change(slot: InventorySlot, from: InventoryItem, to: InventoryItem)

var agressive_update_icon: bool = false

@export var allow_category: Array[String] = []
@export var block_category: Array[String] = []

@export var is_locked: bool = false
@export var max_count: int = HeldItemManager.MAX_ITEM_COUNT

@export var inventory: Inventory:
	set(value):
		inventory = value
		if agressive_update_icon:
			update_icon()
@export var i: int:
	set(value):
		i = value
		if agressive_update_icon:
			update_icon()
@export var j: int:
	set(value):
		j = value
		if agressive_update_icon:
			update_icon()

var slot_owner: Node2D

var contained_item: InventoryItem:
	set(value):
		if is_instance_valid(value) and not is_instance_valid(value.item):
			value = null
		item_change.emit(self, contained_item, value)
		inventory.set_at(i,j,value)
		update_icon()
	get:
		if not is_instance_valid(inventory):
			return null
		return inventory.get_at(i,j)

func _ready() -> void:
	update_icon()

func update_icon() -> void:
#	queue_redraw()
	if is_instance_valid(contained_item):
		icon = contained_item.item.texture
	else:
		icon = null

#func _draw() -> void:
#	if is_instance_valid(contained_item):
#		contained_item.draw(self, Vector2.ZERO)

func _pressed() -> void:
	if HeldItemManager.dragged_item:
		if can_hold_item(HeldItemManager.dragged_item):
			if contained_item:
				#same as current item. add
				if HeldItemManager.dragged_item.item == contained_item.item:
					var item_left := insert_item(HeldItemManager.dragged_item)
					HeldItemManager.dragged_item = item_left
				#not same. try swap.
				elif can_remove_item() and HeldItemManager.dragged_item.count <= max_count:
					#swap items
					var temp = contained_item
					contained_item = HeldItemManager.dragged_item
					HeldItemManager.dragged_item = temp
					HeldItemManager.dragged_item_slot = self
					HeldItemManager.dragged_item_inventory = inventory
					HeldItemManager.dragged_item_owner = slot_owner
			else:
				contained_item = HeldItemManager.dragged_item
				HeldItemManager.reset_item()
	elif contained_item and can_remove_item():
		HeldItemManager.dragged_item = contained_item
		HeldItemManager.dragged_item_slot = self
		HeldItemManager.dragged_item_inventory = inventory
		HeldItemManager.dragged_item_owner = slot_owner
		contained_item = null

func can_hold_item(item: InventoryItem) -> bool:
	var block := not block_category.is_empty() and item.item.item_category in block_category
	var allow := allow_category.is_empty() or item.item.item_category in allow_category
	return allow and not block

func has_place_for_item(item: InventoryItem) -> bool:
	if not contained_item:
		return true
	if item.item != contained_item.item:
		return false
	var max_item_count: int = min(max_count, contained_item.item.item_stack)
	return contained_item.count < max_item_count

func insert_item(item: InventoryItem) -> InventoryItem:
	if item and contained_item and item.item == contained_item.item:
		var max_item_count: int = min(max_count, contained_item.item.item_stack)
		var can_add: int = max_item_count - contained_item.count
		var will_add: int = min(can_add, item.count)
		contained_item.count += will_add
		update_icon()
		item.count -= will_add
		if item.count == 0:
			return null
		else:
			return item
	else:
		contained_item = item
		return null

func can_remove_item() -> bool:
	return not is_locked
