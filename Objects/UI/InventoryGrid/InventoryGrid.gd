extends Inventory
class_name InventoryGrid

@export var allow_category: Array[String] = []
@export var block_category: Array[String] = []

@export var r: int
@export var c: int

func _ready() -> void:
	super._ready()
	if inventory:
		for i in range(c):
			for j in range(r):
				add_slot(i,j,allow_category,block_category)

