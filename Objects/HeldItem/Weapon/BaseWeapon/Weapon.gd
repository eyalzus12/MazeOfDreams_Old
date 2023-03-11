extends Node2D
class_name Weapon

@onready var hitbox := $Base/Sprite2D/Hitbox
@onready var animation_player: AnimationPlayer = get_node_or_null(^"AnimationPlayer")

@export_flags_2d_physics var weapon_layers: int:
	set(value):
		weapon_layers = value
		if not is_inside_tree(): await ready
		hitbox.collision_layer = weapon_layers

@export_flags_2d_physics var weapon_masks: int:
	set(value):
		weapon_masks = value
		if not is_inside_tree(): await ready
		hitbox.collision_mask = weapon_masks

var is_attacking: bool = false

func _ready() -> void:
	if animation_player:
		animation_player.animation_finished.connect(on_animation_finished)

func attack() -> void:
	if not animation_player: return
	if not animation_player.has_animation(&"attack"): return

	animation_player.play(&"attack")
	is_attacking = true

func on_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		&"attack":
			is_attacking = false
			animation_player.play(&"RESET")
			animation_player.advance(0)
			animation_player.stop()
