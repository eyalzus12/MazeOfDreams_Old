extends Node2D

@export var provider: LootProvider

var rand: Random = Random.new()
@export var rand_seed: int = 0

func _ready() -> void:
	update_seed()

func fetch_item() -> void:
	var items: Array[Resource] = provider.provide(rand)
	$GridContainer/Label.text = get_items_description(items)

func get_items_description(items: Array[Resource]) -> String:
	var result: PackedStringArray = []
	for item in items:
		result.append(item.item_name)
	return " ".join(result)

func update_seed() -> void:
	rand_seed = $GridContainer/LineEdit.text.to_int()
	if rand_seed == 0:
		rand.seed_random()
	else:
		rand.seed_with(rand_seed)
