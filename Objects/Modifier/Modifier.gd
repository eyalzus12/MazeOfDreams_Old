extends Node2D
class_name Modifier

var entity: Character:
	set(value):
		if not is_inside_tree():
			await ready
		entity = value
		
		if entity.has_signal(&"attack_started") \
		and not entity.attack_started.is_connected(attack_started):
			entity.attack_started.connect(attack_started)
			
		if entity.has_signal(&"attack_ended") \
		and not entity.attack_ended.is_connected(attack_ended):
			entity.attack_ended.connect(attack_ended)
			
		if entity.has_signal(&"attack_hit") \
		and not entity.attack_hit.is_connected(attack_hit):
			entity.attack_hit.connect(attack_hit)

func attack_started() -> void:
	pass

func attack_ended() -> void:
	pass

func attack_hit(_who: Area2D) -> void:
	pass
