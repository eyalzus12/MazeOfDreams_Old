extends Node2D
class_name ItemModifier

var weapon: Weapon:
	set(value):
		if is_instance_valid(weapon):
			weapon.attack_started.disconnect(attack_start)
			weapon.attack_ended.disconnect(attack_end)
			weapon.attack_hit.disconnect(attack_hit)
		weapon = value
		if not is_inside_tree(): await ready
		if is_instance_valid(weapon):
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
