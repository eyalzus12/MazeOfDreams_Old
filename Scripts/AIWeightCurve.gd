extends Resource
class_name AIWeightCurve

@export var value: float = 0
@export var distance_transform_mult: float = 100
@export var product_weight: float = 1
@export var positive_curve: Curve
@export var negative_curve: Curve

func get_score(position: Vector2, target: Vector2, option: Vector2) -> float:
	return get_distance_mult(position,target)*get_raw_score(position,target,option)*product_weight

func get_distance_mult(position: Vector2, target: Vector2) -> float:
	return distance_transform(abs(value-position.distance_to(target)))

func get_raw_score(position: Vector2, target: Vector2, option: Vector2) -> float:
	var dot := position.direction_to(target).dot(option)
	if dot >= 0 and positive_curve:
		dot = positive_curve.sample(dot)
	elif dot < 0 and negative_curve:
		dot = negative_curve.sample(dot+1)
	return dot

func distance_transform(distance: float) -> float:
	distance /= distance_transform_mult
	return exp(-(distance*distance)/2.0)
	#return 1.0/(distance/distance_transform_mult+1.0)
