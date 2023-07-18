extends Resource
class_name InventoryResource

@export var items: Array[InventoryItem]
@export var columns: int = 10

func size() -> int:
	return items.size()

func ensure_size(size_: int) -> void:
	if items.size() < size_:
		items.resize(size_)

func has_at(i: int, j: int) -> bool:
	return i*columns+j < items.size()

func get_at(i: int, j: int) -> InventoryItem:
	return items[i*columns+j]

func set_at(i: int, j: int, value: InventoryItem) -> void:
	items[i*columns+j] = value
