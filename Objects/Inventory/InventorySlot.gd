extends Button
class_name InventorySlot

@export var contained_item: Item

func _process(_delta: float) -> void:
	if contained_item:
		icon = contained_item.texture
	else:
		icon = null

func _pressed() -> void:
	if Globals.dragged_item:
		if can_hold_item(Globals.dragged_item):
			if contained_item:
				#swap items
				var temp = contained_item
				contained_item = Globals.dragged_item
				Globals.dragged_item = temp
				
				Globals.dragged_item_slot = self
			else:
				contained_item = Globals.dragged_item
				Globals.dragged_item = null
				Globals.dragged_item_slot = null
	elif contained_item:
		Globals.dragged_item = contained_item
		Globals.dragged_item_slot = self
		contained_item = null

func can_hold_item(_item: Item) -> bool:
	return true
