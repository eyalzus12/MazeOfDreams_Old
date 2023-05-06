extends Button
class_name InventorySlot

signal item_change(slot: InventorySlot, from: Item, to: Item)

@export var allow_category: Array[String] = []
@export var block_category: Array[String] = []

@export var is_locked: bool = false

@export var inventory: Inventory
@export var i: int
@export var j: int

var slot_owner: Node2D

var contained_item: Item:
	set(value):
		item_change.emit(self, contained_item, value)
		inventory.set_at(i,j,value)
	get:
		return inventory.get_at(i,j)

func _process(_delta: float) -> void:
	if is_instance_valid(contained_item):
		icon = contained_item.texture
	else:
		icon = null

func _pressed() -> void:
	if Globals.dragged_item:
		if can_hold_item(Globals.dragged_item):
			if contained_item:
				if can_remove_item():
					#swap items
					var temp = contained_item
					contained_item = Globals.dragged_item
					Globals.dragged_item = temp
					Globals.dragged_item_slot = self
					Globals.dragged_item_inventory = inventory
					Globals.dragged_item_owner = slot_owner
			else:
				contained_item = Globals.dragged_item
				Globals.reset_item()
	elif contained_item and can_remove_item():
		Globals.dragged_item = contained_item
		Globals.dragged_item_slot = self
		Globals.dragged_item_inventory = inventory
		Globals.dragged_item_owner = slot_owner
		contained_item = null

func can_hold_item(item: Item) -> bool:
	var block := not block_category.is_empty() and item.item_category in block_category
	var allow := allow_category.is_empty() or item.item_category in allow_category
	return allow and not block

func can_remove_item() -> bool:
	return not is_locked
