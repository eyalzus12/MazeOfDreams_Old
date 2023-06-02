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
