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
	Logger.info(str("given seed: ", given_seed))
	Logger.info(str("hashed seed: ", seed))

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

func random_point_between_Vector2i(from: Vector2i, to: Vector2i) -> Vector2i:
	return Vector2i(randi_range(from.x,to.x),randi_range(from.y,to.y))

#TODO: figure out how to not have to reroll
func chance(of: float) -> bool:
	var roll := 1.
	while roll == 1.:
		roll = randf_range(0,1)
	return roll < of
