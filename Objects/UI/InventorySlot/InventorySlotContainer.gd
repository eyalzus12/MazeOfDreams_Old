extends AspectRatioContainer
class_name InventorySlotContainer
@export var allow_category: Array[String] = []
@export var block_category: Array[String] = []

@export var inventory: Inventory
@export var i: int
@export var j: int

@onready var slot: InventorySlot = $InventorySlot

func _ready() -> void:
	slot.allow_category = allow_category
	slot.block_category = block_category
	slot.inventory = inventory
	slot.i = i
	slot.j = j
