extends Node2D
class_name Modifier

var modifier_owner: Node:
	set(value):
		if not is_inside_tree():
			await ready
		modifier_owner = value
		
		if modifier_owner.has_signal(&"attack_started") \
		and not modifier_owner.attack_started.is_connected(attack_started):
			modifier_owner.attack_started.connect(attack_started)
			
		if modifier_owner.has_signal(&"attack_ended") \
		and not modifier_owner.attack_ended.is_connected(attack_ended):
			modifier_owner.attack_ended.connect(attack_ended)
			
		if modifier_owner.has_signal(&"attack_hit") \
		and not modifier_owner.attack_hit.is_connected(attack_hit):
			modifier_owner.attack_hit.connect(attack_hit)

func attack_started() -> void:
	pass

func attack_ended() -> void:
	pass

func attack_hit(_who: Area2D) -> void:
	pass
