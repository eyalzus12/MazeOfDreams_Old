extends CharacterBody2D
class_name Character

signal attack_started
signal attack_ended
signal attack_hit(who: Area2D)

@onready var dash_cooldown_timer: Timer = $DashCooldownTimer
@onready var in_dash_timer: Timer = $InDashTimer
@onready var iframes_timer: Timer = $InvincibilityTimer

@onready var hurtbox: Hurtbox = $Hurtbox
@onready var sprite: Sprite2D = $Sprite
@onready var debug_label: Label = $UILayer/DebugLabel
@onready var health_bar: TextureProgressBar = $UILayer/HealthBar
@onready var inventory: GridContainer = $UILayer/InventoryGrid

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
			weapon.attack_started.disconnect(_attack_started)
			weapon.attack_ended.disconnect(_attack_ended)
			weapon.attack_hit.disconnect(_attack_hit)
			weapon.process_mode = Node.PROCESS_MODE_DISABLED
			weapon.visible = false
		weapon = value
		if is_instance_valid(weapon):
			weapon.attack_started.connect(_attack_started)
			weapon.attack_ended.connect(_attack_ended)
			weapon.attack_hit.connect(_attack_hit)
			weapon.process_mode = Node.PROCESS_MODE_INHERIT
			weapon.visible = true
			weapon._ready()
			
@export var item_modifiernp: Array[NodePath]
var active_item_modifiers: ItemModifierCollection
var inactive_item_modifiers: ItemModifierCollection
		
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
	active_item_modifiers = ItemModifierCollection.new(self, [])
	inactive_item_modifiers = ItemModifierCollection.new(self, item_modifiernp)
	
	var current_modifiers := inactive_item_modifiers.get_modifiers()
	for modifier in current_modifiers:
		activate_modifier(modifier)
	
	#temp code. remove.
	var slot1 := inventory.get_child(0).get_node(^"InventorySlot") as InventorySlot
	slot1.contained_item = load("res://Testing/TestSwordItem.tres")
	var slot2 := inventory.get_child(1).get_node(^"InventorySlot") as InventorySlot
	slot2.contained_item = load("res://Testing/TestHammerItem.tres")
	
func _physics_process(_delta: float) -> void:
	if is_zero_approx(velocity.x): velocity.x = 0
	if is_zero_approx(velocity.y): velocity.y = 0

	if Input.is_action_just_pressed(&"toggle_debug"): debug_active = not debug_active
	debug_label.visible = debug_active
	if debug_active: debug_label.update_text(self)
	
	if Input.is_action_just_pressed(&"inventory_open"):
		#toggle inventory visibility.
		inventory.visible = not inventory.visible
		#closing inventory. handle putting item back in slot.
		if not inventory.visible and Globals.dragged_item:
			#original slot has an item. find available slot.
			if Globals.dragged_item_slot.contained_item:
				var found_slot := false
				#go over slots
				for child in inventory.get_children():
					var slot := child.get_node(^"InventorySlot") as InventorySlot
					#found empty one. set item.
					if not slot.contained_item:
						found_slot = true
						slot.contained_item = Globals.dragged_item
						break
				#none empty.
				if not found_slot:
					push_error("oopsy doopsy! the inventory was closed with an item held, and there's no place in the inventory to put it! items on the floor aren't properly implemented yet, so this is a fun little memory leak")
			#can safetly put in origin slot.
			else:
				Globals.dragged_item_slot.contained_item = Globals.dragged_item
			Globals.dragged_item = null
			Globals.dragged_item_slot = null

func set_direction() -> void:
	direction = global_position.direction_to(get_global_mouse_position())

	if direction.x > 0 and sprite.flip_h:
		sprite.flip_h = false
	elif direction.x < 0 and not sprite.flip_h:
		sprite.flip_h = true
	
	if is_instance_valid(weapon):
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

func _attack_started() -> void:
	emit_signal(&"attack_started")
func _attack_ended() -> void:
	emit_signal(&"attack_ended")
func _attack_hit(who: Node2D) -> void:
	emit_signal(&"attack_hit", who)

func activate_modifier(modifier: ItemModifier) -> void:
	if active_item_modifiers.has(modifier): return
	if inactive_item_modifiers.has(modifier):
		inactive_item_modifiers.remove(modifier)
		active_item_modifiers.add(modifier)
		modifier.process_mode = Node.PROCESS_MODE_INHERIT

func deactive_modifier(modifier: ItemModifier) -> void:
	if inactive_item_modifiers.has(modifier): return
	if active_item_modifiers.has(modifier):
		active_item_modifiers.remove(modifier)
		inactive_item_modifiers.add(modifier)
		modifier.process_mode = Node.PROCESS_MODE_DISABLED
