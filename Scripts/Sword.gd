extends Node2D
class_name Sword

onready var animation_player: AnimationPlayer = $SwordAnimationPlayer
onready var hitbox: Hitbox = $SwordHitbox

func attack() -> void:
	animation_player.play("sword_attack")

func _on_SwordAnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"sword_attack":
			animation_player.play("RESET")
			animation_player.advance(0)
			animation_player.stop(true)
