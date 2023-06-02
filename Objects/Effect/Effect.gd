extends Node2D
class_name Effect

@onready var timer: Timer = $EffectTimer
@export var time_left: float

var effect_owner: Node

var effect_type: String: get = get_effect_type

func get_effect_type() -> String:
	if has_meta("effect_type"):
		return get_meta("effect_type")
	return ""

func _ready() -> void:
	timer.start(time_left)

func _on_timer_timeout() -> void:
	ObjectPool.return_object(self)

func pool_cleanup() -> void:
	if effect_owner.has_method(&"remove_effect"):
		effect_owner.remove_effect(self)

func update_with_time(new_time: float) -> void:
	if not is_inside_tree():
		await ready
	var timer_time_left: float = timer.time_left
	if timer_time_left < new_time:
		timer.start(new_time)
