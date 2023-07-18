extends LootProvider
class_name SingleLootProvider

@export var loot: Resource

@warning_ignore("unused_parameter")
func provide(rand: Random) -> Array[Resource]:
	return [loot]
