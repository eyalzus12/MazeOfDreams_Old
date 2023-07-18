extends LootProvider
class_name RandomWeightedLootProvider

@export var options: Array[LootProvider] = []
@export var weights: Array[int] = []

func provide(rand: Random) -> Array[Resource]:
	return finalize_option(rand, rand.pick_random_weighted(options, weights))
