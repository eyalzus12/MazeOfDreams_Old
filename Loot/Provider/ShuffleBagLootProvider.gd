extends LootProvider
class_name ShuffleBagLootProvider

@export var options: Array[LootProvider] = []
@export var picks_before_reshuffle: int = -1

var init_shuffle: bool = false
var discards: Array[LootProvider] = []

func provide(rand: Random) -> Array[Resource]:
	if not init_shuffle:
		reshuffle(rand)
		init_shuffle = true
	
	if should_reshuffle():
		reshuffle(rand)
	if options.is_empty():
		Logger.error(str("attempt to get item from empty shuffle bag"))
		return []
	var choice: LootProvider = options.back()
	discards.push_back(options.pop_back())
	return finalize_option(rand, choice)

func should_reshuffle() -> bool:
	if picks_before_reshuffle == -1:
		return options.is_empty()
	else:
		return discards.size() > picks_before_reshuffle

func reshuffle(rand: Random) -> void:
	options.append_array(discards)
	discards.clear()
	rand.shuffle(options)
