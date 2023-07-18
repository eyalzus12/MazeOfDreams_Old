extends LootProvider
class_name RandomLootProvider

@export var options: Array[LootProvider] = []

func provide(rand: Random) -> Array[Resource]:
	return finalize_option(rand, rand.pick_random(options))
