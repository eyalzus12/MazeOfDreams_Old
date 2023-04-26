extends Resource
class_name AIWeight

@export var weight_type: String
@export var weight_multiplier: float = 1
@export var weight_curves: Array[AIWeightCurve] = []
var target: Vector2 = Vector2(NAN,NAN)

func get_score(position: Vector2, option: Vector2) -> float:
	if is_nan(target.x): return 0
	if weight_curves.is_empty(): return 0
	var sum: float = 0
	for weight_curve in weight_curves:
		if weight_curve:
			sum += weight_curve.get_score(position,target,option)
	return weight_multiplier*sum/weight_curves.size()
