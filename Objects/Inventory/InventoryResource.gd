extends Resource
class_name InventoryResource

@export var items: Array[Item]
@export var columns: int = 10

func ensure_size(size: int) -> void:
	if items.size() < size:
		items.resize(size)

func get_at(i: int, j: int) -> Item:
	return items[i*columns+j]

func set_at(i: int, j: int, value: Item) -> void:
	items[i*columns+j] = value
