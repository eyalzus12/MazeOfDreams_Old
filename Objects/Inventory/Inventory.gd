extends GridContainer
class_name Inventory

const SLOT := preload("res://Objects/UI/InventorySlot/InventorySlot.tscn")

signal item_change(slot: InventorySlot, from: InventoryItem, to: InventoryItem)

@export var inventory: InventoryResource
@export var pickup_target: bool
var slots: Array[InventorySlot]

var inventory_owner: Node2D:
	set(value):
		inventory_owner = value
		for slot in slots:
			slot.slot_owner = value

var is_open: bool:
	set(value):
		if is_open == value: return
		is_open = value
		if is_open: _open()
		else: _close()

func _ready() -> void:
	HeldItemManager.inventories[self] = null
	if inventory:
		columns = inventory.columns

func _exit_tree() -> void:
	HeldItemManager.inventories.erase(self)

func add_slot(i: int, j: int, allow_category: Array, block_category: Array, max_count: int):
	if inventory:
		var slot_container: InventorySlotContainer = ObjectPool.load_object(SLOT,10,20)
		slot_container.allow_category = allow_category
		slot_container.block_category = block_category
		slot_container.max_count = max_count
		slot_container.inventory = self
		slot_container.i = i
		slot_container.j = j
		slot_container.item_change.connect(_item_change)
		add_child(slot_container)
		var slot: InventorySlot = slot_container.slot
		slots.append(slot)

func _item_change(slot: InventorySlot, from: InventoryItem, to: InventoryItem) -> void:
	item_change.emit(slot,from,to)

func open() -> void:
	is_open = true
func close() -> void:
	is_open = false
func toggle() -> void:
	is_open = not is_open

func _open() -> void:
	visible = true
	HeldItemManager.open_inventories[self] = null

func _close() -> void:
	visible = false
	HeldItemManager.open_inventories.erase(self)
	#closing inventory of held item. handle putting it back in.
	if HeldItemManager.dragged_item_inventory == self:
		#original slot has an item. find available slot.
		if HeldItemManager.dragged_item_slot.contained_item:
			var item_left := try_insert(HeldItemManager.dragged_item)
			HeldItemManager.dragged_item = item_left
			if item_left:
				HeldItemManager.drop_item(HeldItemManager.dragged_item, global_position)
		#can safetly put in origin slot.
		else:
			HeldItemManager.dragged_item_slot.contained_item = HeldItemManager.dragged_item
		HeldItemManager.reset_item()

#calls HeldItemManager.return_dragged_item(), only if it's the inventory that the item is from
func return_dragged_item() -> void:
	if HeldItemManager.dragged_item_inventory == self:
		HeldItemManager.return_dragged_item()

func find_insert_location(item: InventoryItem) -> InventorySlot:
	for slot in slots:
		if slot.has_place_for_item(item) and slot.can_hold_item(item):
			return slot
	return null

func has_insert_location(item: InventoryItem) -> bool:
	return find_insert_location(item) != null

func try_insert(item: InventoryItem) -> InventoryItem:
	#first try to group stuff together, so ignore empty slots
	for slot in slots:
		if slot.contained_item and slot.has_place_for_item(item) and slot.can_hold_item(item):
			item = slot.insert_item(item)
			if not item:
				return null
	#now we check for empty slots
	for slot in slots:
		if not slot.contained_item and slot.can_hold_item(item):
			item = slot.insert_item(item)
			if not item:
				return null
	return item

func get_at(i: int, j: int) -> InventoryItem:
	return inventory.get_at(i,j)

func set_at(i: int, j: int, value: InventoryItem) -> void:
	inventory.set_at(i,j,value)

func try_insert_item_list(items: Array[Resource]) -> void:
	for item in items:
		if not item is Item:
			Logger.error(str("attempt to insert item list with non item resource ",item))
			break
		var iitem: InventoryItem = InventoryItem.new()
		iitem.item = item
		iitem.count = 1
		var remain := try_insert(iitem)
		if remain != null:
			Logger.warn(str("space to insert items to inventory ended mid insertion"))
			break

func populate_with_provider(rand: Random, provider: LootProvider) -> void:
	try_insert_item_list(provider.provide(rand))

func pool_cleanup() -> void:
	for slot in slots:
		ObjectPool.return_object(slot)
