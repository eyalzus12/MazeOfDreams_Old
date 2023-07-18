extends LootProvider
class_name RepeatedLootProvider

@export var min_amount: int = 1
@export var max_amount: int = 1
@export var option: LootProvider

func provide(rand: Random) -> Array[Resource]:
	var amount: int = rand.randi_range(min_amount, max_amount)
	var result: Array[Resource] = []
	for __ in range(amount):
		result.append_array(finalize_option(rand, option))
	return result
