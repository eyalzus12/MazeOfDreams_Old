extends GridContainer
class_name Inventory

const SLOT := preload("res://Objects/UI/InventorySlot/InventorySlot.tscn")

@export var inventory: InventoryResource
var slots: Array[InventorySlot]

var is_open: bool:
	set(value):
		if is_open == value: return
		is_open = value
		if is_open: _open()
		else: _close()

func _ready() -> void:
	if inventory:
		columns = inventory.columns

func add_slot(i: int, j: int, allow_category: Array, block_category: Array):
	if inventory:
		var slot_container: InventorySlotContainer = SLOT.instantiate()
		slot_container.allow_category = allow_category
		slot_container.block_category = block_category
		slot_container.inventory = self
		slot_container.i = i
		slot_container.j = j
		add_child(slot_container)
		var slot: InventorySlot = slot_container.slot
		slots.append(slot)

func open() -> void:
	is_open = true
func close() -> void:
	is_open = false
func toggle() -> void:
	is_open = not is_open

func _open() -> void:
	visible = true
	Globals.open_inventories[self] = null

func _close() -> void:
	visible = false
	Globals.open_inventories.erase(self)
	#closing inventory of held item. handle putting it back in.
	if Globals.dragged_item_inventory == self:
		#original slot has an item. find available slot.
		if Globals.dragged_item_slot.contained_item:
			var found_slot := false
			#go over slots
			for slot in Globals.dragged_item_inventory.slots:
				#found empty one. set item.
				if not slot.contained_item:
					found_slot = true
					slot.contained_item = Globals.dragged_item
					break
			#none empty.
			if not found_slot:
				push_error("oopsy doopsy! the inventory was closed with an item held, and there's no place in the inventory to put it! items on the floor aren't properly implemented yet, so this is a fun little memory leak")
		#can safetly put in origin slot.
		else:
			Globals.dragged_item_slot.contained_item = Globals.dragged_item
		Globals.dragged_item = null
		Globals.dragged_item_inventory = null
		Globals.dragged_item_slot = null

func get_at(i: int, j: int) -> Item:
	return inventory.get_at(i,j)

func set_at(i: int, j: int, value: Item) -> void:
	inventory.set_at(i,j,value)
