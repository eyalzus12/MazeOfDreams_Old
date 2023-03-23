extends Node2D
class_name ItemModifier

var weapon: Weapon:
	set(value):
		weapon = value
		if not is_inside_tree(): await ready
		weapon.attack_started.connect(attack_start)
		weapon.attack_ended.connect(attack_end)
		weapon.attack_hit.connect(attack_hit)

var entity: Character

func attack_start() -> void:
	pass

func attack_end() -> void:
	pass

func attack_hit(_who: Area2D) -> void:
	pass
