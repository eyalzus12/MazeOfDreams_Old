extends Resource
class_name LootProvider

@warning_ignore("unused_parameter")
func provide(rand: Random) -> Array[Resource]:
	Logger.error(str("attempt to get item from a plain LootProvider ",self))
	return []

func finalize_option(rand: Random, option: Resource) -> Array[Resource]:
	if option is LootProvider:
		return (option as LootProvider).provide(rand)
	else:
		return [option]
