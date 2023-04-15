extends CharacterBody2D
class_name Character

@onready var dash_cooldown_timer: Timer = $DashCooldownTimer
@onready var in_dash_timer: Timer = $InDashTimer
@onready var iframes_timer: Timer = $InvincibilityTimer

@onready var hurtbox: Hurtbox = $Hurtbox
@onready var sprite: Sprite2D = $Sprite
@onready var debug_label: Label = $UILayer/DebugLabel
@onready var health_bar: TextureProgressBar = $UILayer/HealthBar

var state_frame: int
var current_state: String

@export var speed: float = 300
@export var acceleration: float = 50
@export var dash_startup: float = 2
@export var dash_speed: float = 1000
@export var dash_bounce_mult: float = 1.3
@export var weapon: Weapon:
	set(value):
		if not is_inside_tree():
			await ready
		if is_instance_valid(weapon):
			weapon.process_mode = Node.PROCESS_MODE_DISABLED
			weapon.visible = false
		weapon = value
		if is_instance_valid(weapon):
			weapon.process_mode = Node.PROCESS_MODE_INHERIT
			weapon.visible = true
			weapon._ready()
		for item_modifier in item_modifiers:
			if is_instance_valid(item_modifier):
				item_modifier.weapon = weapon
			
@export var item_modifiernp: Array[NodePath]
@onready var item_modifiers: Array[Node2D]:
	set(value):
		if not is_inside_tree():
			await ready
		
		item_modifiers = value
		for item_modifier in item_modifiers:
			if is_instance_valid(item_modifier):
				item_modifier.weapon = weapon
				item_modifier.entity = self
		
@export var dash_cooldown: float:
	set(value):
		dash_cooldown = value
		if not is_inside_tree():
			await ready
		dash_cooldown_timer.wait_time = dash_cooldown

@export var dash_time: float:
	set(value):
		dash_time = value
		if not is_inside_tree():
			await ready
		in_dash_timer.wait_time = dash_time

@export var initial_hp: float = 100

@export var current_hp: float = initial_hp :
	set(value):
		current_hp = value
		if not is_inside_tree():
			await ready
		health_bar.set_health(current_hp)

@export var stun_friction: float = 0.5

@export var i_frames: float:
	set(value):
		i_frames = value
		if not is_inside_tree():
			await ready
		iframes_timer.wait_time = i_frames

var dash_in_cooldown: bool = false
var in_dash: bool = false

var direction: Vector2

var input_vector: Vector2
var velocity_vector: Vector2

var left: bool
var right: bool
var up: bool
var down: bool

var debug_active: bool = false

func _ready() -> void:
	item_modifiers.assign(item_modifiernp.map(get_node))
	#hack to get the setter to function
	item_modifiers = item_modifiers
	
func _physics_process(_delta: float) -> void:
	if is_zero_approx(velocity.x): velocity.x = 0
	if is_zero_approx(velocity.y): velocity.y = 0

	if Input.is_action_just_pressed(&"toggle_debug"): debug_active = not debug_active
	debug_label.visible = debug_active
	if debug_active: debug_label.update_text(self)

func set_direction() -> void:
	direction = global_position.direction_to(get_global_mouse_position())

	if direction.x > 0 and sprite.flip_h:
		sprite.flip_h = false
	elif direction.x < 0 and not sprite.flip_h:
		sprite.flip_h = true

	weapon.rotation = direction.angle()
	if weapon.scale.y == 1 and direction.x < 0:
		weapon.scale.y = -1
	elif weapon.scale.y == -1 and direction.x > 0:
		weapon.scale.y = 1

func set_inputs() -> void:
	set_horizontal_inputs()
	set_vertical_inputs()
	input_vector = \
		int(left)*Vector2.LEFT + \
		int(right)*Vector2.RIGHT + \
		int(down)*Vector2.DOWN + \
		int(up)*Vector2.UP
	velocity_vector = input_vector.normalized()


func set_horizontal_inputs() -> void:
	if Input.is_action_just_pressed(&"player_left"):
		left = true
		right = false
	if Input.is_action_just_pressed(&"player_right"):
		left = false
		right = true
	if not Input.is_action_pressed(&"player_left"):
		left = false
	if not Input.is_action_pressed(&"player_right"):
		right = false
	if Input.is_action_pressed(&"player_left") and not right:
		left = true
	if Input.is_action_pressed(&"player_right") and not left:
		right = true

func set_vertical_inputs() -> void:
	if Input.is_action_just_pressed(&"player_up"):
		up = true
		down = false
	if Input.is_action_just_pressed(&"player_down"):
		up = false
		down = true
	if not Input.is_action_pressed(&"player_up"):
		up = false
	if not Input.is_action_pressed(&"player_down"):
		down = false
	if Input.is_action_pressed(&"player_up") and not down:
		up = true
	if Input.is_action_pressed(&"player_down") and not up:
		down = true

