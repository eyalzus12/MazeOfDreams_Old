extends RandomNumberGenerator
class_name Random

#use this to indicate what seed the world generated with
var given_seed

#kinda weird to seed with the seed
#but eh who cares
func seed_random() -> void:
	super.randomize()
	seed_with(seed)

func seed_with(x) -> void:
	given_seed = x
	seed = hash(x)
	Logger.logs(str("given seed: ", given_seed))
	Logger.logs(str("hashed seed: ", seed))

func random_point_in_circle(r: float) -> Vector2:
	#random polar
	var r_random := r * sqrt(randf())
	var θ_random := TAU * randf()
	#convert to cart
	return r_random * Vector2.from_angle(θ_random)

func random_point_in_ring(r_min: float, r_max: float) -> Vector2:
	#random polar
	var r_random := sqrt((r_max**2 - r_min**2)*randf()+r_min**2)
	var θ_random := TAU * randf()
	#convert to cart
	return r_random * Vector2.from_angle(θ_random)

func random_point_in_Rect2i(from: Vector2i, to: Vector2i) -> Vector2i:
	return Vector2i(randi_range(from.x,to.x),randi_range(from.y,to.y))

#TODO: figure out how to not have to reroll
func chance(of: float) -> bool:
	var roll := 1.
	while roll == 1.:
		roll = randf_range(0,1)
	return roll < of

func pick_random(options: Array):
	if options.is_empty():
		Logger.error(str("attempt to pick a random element out of an empty array"))
		return null
	
	return options[randi_range(0,options.size()-1)]

func pick_random_weighted(options: Array, weights: Array[int], accumulated: bool = false):
	if options.is_empty():
		Logger.error(str("attempt to pick a random element out of an empty array"))
		return null
	if options.size() != weights.size():
		Logger.error(str("options array and weights array are unequal"))
		return null
	
	var weights_: Array[int] = []
	if not accumulated:
		weights_ = weights.duplicate()
		for i in range(1,weights.size()):
			weights_[i] += weights_[i-1]
	else:
		weights_ = weights
	
	var chosen_weight: int = randi_range(weights_.front(),weights_.back())
	var chosen_index: int = weights_.bsearch(chosen_weight)
	return options[chosen_index]

#fisher-yate shuffle
func shuffle(arr: Array) -> void:
	for i in range(0,arr.size()-1):
		var j: int = randi_range(i, arr.size()-1)
		# swap i,j
		var temp = arr[i]
		arr[i] = arr[j]
		arr[j] = temp
