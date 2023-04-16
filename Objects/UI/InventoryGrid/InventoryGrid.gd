extends GridContainer

const SLOT := preload("res://Objects/UI/InventorySlot/InventorySlot.tscn")

func _ready() -> void:
	for i in range(columns):
		for j in range(columns):
			var slot := SLOT.instantiate()
			add_child(slot)
