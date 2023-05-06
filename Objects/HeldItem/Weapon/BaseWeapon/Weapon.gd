extends Node2D
class_name Weapon

signal attack_started
signal attack_ended
signal attack_hit(who: Area2D)

@export var weapon_owner: Node:
	set(value):
		if not is_inside_tree():
			await ready
		weapon_owner = value
		if weapon_owner:
			if weapon_owner.has_meta("hitbox_layers"):
				hitbox.layers = weapon_owner.get_meta("hitbox_layers")
			if weapon_owner.has_meta("hitbox_masks"):
				hitbox.masks = weapon_owner.get_meta("hitbox_masks")
			hitbox.hitbox_owner = weapon_owner

@onready var hitbox: Hitbox = $Base/Sprite2D/Hitbox
@onready var animation_player: AnimationPlayer = get_node_or_null(^"AnimationPlayer")

var connected_signals := false

var is_attacking: bool = false

func _ready() -> void:
	if not connected_signals:
		if animation_player:
			animation_player.animation_finished.connect(on_animation_finished)
		if hitbox:
			hitbox.area_entered.connect(on_hit)
		connected_signals = true

func on_hit(area: Area2D) -> void:
	emit_signal(&"attack_hit", area)

func attack() -> void:
	if not animation_player: return
	if not animation_player.has_animation(&"attack"): return
	animation_player.play(&"attack")
	emit_signal(&"attack_started")
	is_attacking = true

func on_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		&"attack":
			emit_signal(&"attack_ended")
			is_attacking = false
			animation_player.play(&"RESET")
			animation_player.advance(0)
			animation_player.stop()
