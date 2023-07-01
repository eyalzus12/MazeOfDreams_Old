extends CharacterBody2D
class_name Enemy

@onready var state_machine: StateMachine = $StateMachine

@onready var iframes_timer: Timer = $InvincibilityTimer

@export var speed: float = 280
@export var acceleration: float = 0.1
@export var initial_hp: float = 100
@export var current_hp: float
@export var stun_friction: float = 0.3
@export var on_hit_velocity_mult: float = 0.5

@export var i_frames: float:
	set(value):
		i_frames = value
		if not is_inside_tree(): await ready
		iframes_timer.wait_time = i_frames

#Dictionary[String,Effect]
var active_effects: Dictionary

func _ready() -> void:
	current_hp = initial_hp

func apply_hit(hitbox: Hitbox) -> void:
	apply_damage(hitbox.damage)
	apply_knockback(hitbox.global_position.direction_to(global_position) \
		* hitbox.pushback)
	state_machine.set_state(state_machine.states.hurt)

func apply_damage(damage: float) -> void:
	current_hp -= damage
	Globals.create_damage_popup(-damage, global_position)

func apply_knockback(vector: Vector2) -> void:
	velocity = vector

func apply_effect(effect: Effect) -> void:
	if effect.effect_type == "":
		Logger.warn(str("trying to apply effect without type: ", effect))
		return
	if not effect.effect_type in active_effects\
	or not is_instance_valid(active_effects[effect.effect_type]):
		active_effects[effect.effect_type] = effect
		add_child(effect)
	active_effects[effect.effect_type].update_with_time(effect.time_left)

func remove_effect(effect: Effect) -> void:
	if effect.effect_type == "":
		Logger.warn(str("trying to remove effect without type: ", effect))
		return
	if not effect.effect_type in active_effects:
		return
	active_effects.erase(effect.effect_type)
