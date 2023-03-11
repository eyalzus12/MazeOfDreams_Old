extends CharacterBody2D
class_name Enemy

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

func _ready() -> void:
	current_hp = initial_hp
