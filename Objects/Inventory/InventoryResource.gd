extends Resource
class_name InventoryResource

@export var items: Array[InventoryItem]
@export var columns: int = 10

func ensure_size(size: int) -> void:
	if items.size() < size:
		items.resize(size)

func get_at(i: int, j: int) -> InventoryItem:
	return items[i*columns+j]

func set_at(i: int, j: int, value: InventoryItem) -> void:
	items[i*columns+j] = value
