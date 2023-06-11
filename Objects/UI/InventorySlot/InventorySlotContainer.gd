extends AspectRatioContainer
class_name InventorySlotContainer

signal item_change(slot_: InventorySlot, from: Item, to: Item)

@export var allow_category: Array[String] = []
@export var block_category: Array[String] = []

@export var is_locked: bool = false

@export var inventory: Inventory
@export var i: int
@export var j: int

@onready var slot: InventorySlot = $InventorySlot

func _ready() -> void:
	slot.allow_category = allow_category
	slot.block_category = block_category
	slot.is_locked = is_locked
	slot.inventory = inventory
	slot.i = i
	slot.j = j
	slot.agressive_update_icon = true
	slot.update_icon()
	
	#for some reason simply connecting to item_change.emit doesn't work. so this is needed.
	slot.item_change.connect(_item_change)

func _item_change(slot_: InventorySlot, from: Item, to: Item) -> void:
	item_change.emit(slot_,from,to)
