extends Resource
class_name AIBrain

@export var weight_types: Array[AIWeight]

var weight_bases: Dictionary = {}

#Dictionary[String, Dictionary[String, AIWeight]]
var weights: Dictionary = {}

func init_weights() -> void:
	for weight_type in weight_types:
		weight_bases[weight_type.weight_type] = weight_type
		weights[weight_type.weight_type] = {}

func place_weight(type: String, name: String, position: Vector2) -> void:
	weights[type][name] = weight_bases[type].duplicate()
	weights[type][name].target = position

func remove_weight(type: String, name: String) -> void:
	weights[type].erase(name)

func move_weight(type: String, name: String, position: Vector2) -> void:
	weights[type][name].target = position

func get_total_score(position: Vector2, option: Vector2) -> float:
	var scores := get_scores(position, option)
	var sum: float = 0
	for score in scores: sum += score
	return sum

func get_scores(position: Vector2, option: Vector2) -> Array[float]:
	var result: Array[float] = []
	for weight_type in weights.values():
		for weight in weight_type.values():
			result.append(weight.get_score(position, option))
	return result

func get_best(position: Vector2, precision: int = 100) -> Vector2:
	var dir := Vector2.ZERO
	for i in range(precision):
		var actual := remap(i, 0, precision, 0, TAU)
		var vec := Vector2.from_angle(actual)
		var score := get_total_score(position, vec)
		dir += score*vec
	return dir.normalized()
