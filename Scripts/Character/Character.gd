extends CharacterBody2D
class_name Character

@onready var dash_cooldown_timer: Timer = $DashCooldownTimer
@onready var in_dash_timer: Timer = $InDashTimer
@onready var iframes_timer: Timer = $InvincibilityTimer

@onready var sword: Sword = $Sword
@onready var hurtbox: Hurtbox = $Hurtbox
@onready var sprite: Sprite2D = $Sprite2D
@onready var debug_label: Label = $UILayer/DebugLabel
@onready var health_bar: TextureProgressBar = $UILayer/HealthBar

var state_frame: int
var current_state: String

@export var speed: float = 300
@export var acceleration: float = 50
@export var dash_startup: float = 2
@export var dash_speed: float = 1000
@export var dash_bounce_mult: float = 1.3
@export var dash_cooldown: float = 0.5 : set = set_dash_cooldown
@export var dash_time: float = 0.2 : set = set_dash_time
@export var initial_hp: float = 100
@export var current_hp: float = initial_hp : set = set_current_hp
@export var stun_friction: float = 0.5
@export var i_frames: float = 0.5 : set = set_i_frames

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
	set_dash_cooldown(dash_cooldown)
	set_dash_time(dash_time)
	set_i_frames(i_frames)
	set_current_hp(current_hp)

func _physics_process(_delta: float) -> void:
	if is_zero_approx(velocity.x): velocity.x = 0
	if is_zero_approx(velocity.y): velocity.y = 0
	
	if Input.is_action_just_pressed("toggle_debug"): debug_active = not debug_active
	debug_label.visible = debug_active
	if debug_active: debug_label.update_text(self)

func set_direction() -> void:
	direction = global_position.direction_to(get_global_mouse_position())
	
	if direction.x > 0 and sprite.flip_h:
		sprite.flip_h = false
	elif direction.x < 0 and not sprite.flip_h:
		sprite.flip_h = true
	
	sword.rotation = direction.angle()
	if sword.scale.y == 1 and direction.x < 0:
		sword.scale.y = -1
	elif sword.scale.y == -1 and direction.x > 0:
		sword.scale.y = 1

func set_inputs() -> void:
	set_horizontal_inputs()
	set_vertical_inputs()
	input_vector = \
		(Vector2.LEFT if left else Vector2.ZERO) + \
		(Vector2.RIGHT if right else Vector2.ZERO) + \
		(Vector2.UP if up else Vector2.ZERO) + \
		(Vector2.DOWN if down else Vector2.ZERO)
	velocity_vector = Vector2.ZERO if input_vector == Vector2.ZERO else input_vector.normalized()
	

func set_horizontal_inputs() -> void:
	if Input.is_action_just_pressed("player_left"):
		left = true
		right = false
	if Input.is_action_just_pressed("player_right"):
		left = false
		right = true
	if not Input.is_action_pressed("player_left"):
		left = false
	if not Input.is_action_pressed("player_right"):
		right = false
	if Input.is_action_pressed("player_left") and not right:
		left = true
	if Input.is_action_pressed("player_right") and not left:
		right = true

func set_vertical_inputs() -> void:
	if Input.is_action_just_pressed("player_up"):
		up = true
		down = false
	if Input.is_action_just_pressed("player_down"):
		up = false
		down = true
	if not Input.is_action_pressed("player_up"):
		up = false
	if not Input.is_action_pressed("player_down"):
		down = false
	if Input.is_action_pressed("player_up") and not down:
		up = true
	if Input.is_action_pressed("player_down") and not up:
		down = true

func set_i_frames(f: float) -> void:
	i_frames = f
	if is_inside_tree(): iframes_timer.wait_time = f

func set_dash_time(f: float) -> void:
	dash_time = f
	if is_inside_tree(): in_dash_timer.wait_time = f

func set_dash_cooldown(f: float) -> void:
	dash_cooldown = f
	if is_inside_tree(): dash_cooldown_timer.wait_time = f

func set_current_hp(hp: float) -> void:
	current_hp = hp
	if is_inside_tree(): health_bar.set_health(current_hp)
