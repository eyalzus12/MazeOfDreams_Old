extends Node2D
class_name Sword

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var is_attacking: bool = false

func attack() -> void:
	animation_player.play(&"sword_attack")
	is_attacking = true

func _on_SwordAnimationPlayer_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		&"sword_attack":
			is_attacking = false
			animation_player.play(&"RESET")
			animation_player.advance(0)
			animation_player.stop(true)
