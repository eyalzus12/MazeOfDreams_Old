extends GridContainer
class_name Inventory

const SLOT := preload("res://Objects/UI/InventorySlot/InventorySlot.tscn")

@export var inventory: InventoryResource
@export var pickup_target: bool
var slots: Array[InventorySlot]

var is_open: bool:
	set(value):
		if is_open == value: return
		is_open = value
		if is_open: _open()
		else: _close()

func _ready() -> void:
	Globals.inventories[self] = null
	if inventory:
		columns = inventory.columns

func _exit_tree() -> void:
	Globals.inventories.erase(self)

func add_slot(i: int, j: int, allow_category: Array, block_category: Array):
	if inventory:
		var slot_container: InventorySlotContainer = ObjectPool.load_object(SLOT)
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
			var has_space := try_insert(Globals.dragged_item)
			if not has_space:
				Globals.drop_item(Globals.dragged_item, global_position)
		#can safetly put in origin slot.
		else:
			Globals.dragged_item_slot.contained_item = Globals.dragged_item
		Globals.dragged_item = null
		Globals.dragged_item_inventory = null
		Globals.dragged_item_slot = null

func try_insert(item: Item) -> bool:
	for slot in slots:
		if not slot.contained_item:
			slot.contained_item = item
			return true
	return false

func get_at(i: int, j: int) -> Item:
	return inventory.get_at(i,j)

func set_at(i: int, j: int, value: Item) -> void:
	inventory.set_at(i,j,value)
