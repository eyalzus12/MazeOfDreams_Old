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
@onready var inventory: InventoryGrid = $UILayer/InventoryGrid

@onready var weapon_slots: InventoryGrid = $UILayer/EquipSlots/EquipWeapon
@onready var a_slots: InventoryGrid = $UILayer/EquipSlots/EquipA
@onready var b_slots: InventoryGrid = $UILayer/EquipSlots/EquipB


@onready var state_machine: StateMachine = $StateMachine

var state_frame: int:
	get:
		return state_machine.state_frame
var current_state: String:
	get:
		return state_machine.state_names[state_machine.state]


@export var speed: float = 300
@export var acceleration: float = 50
@export var dash_startup: float = 2
@export var dash_speed: float = 1000
@export var dash_bounce_mult: float = 1.3

var weapon_slot: InventorySlot

var weapon: Weapon:
	set(value):
		if not is_inside_tree():
			await ready
		if is_instance_valid(weapon):
			ObjectPool.return_object(weapon)
		weapon = value
		if is_instance_valid(weapon):
			weapon.weapon_owner = self
			add_child(weapon)
			if not weapon.attack_started.is_connected(_attack_started):
				weapon.attack_started.connect(_attack_started)
			if not weapon.attack_ended.is_connected(_attack_ended):
				weapon.attack_ended.connect(_attack_ended)
			if not weapon.attack_hit.is_connected(_attack_hit):
				weapon.attack_hit.connect(_attack_hit)
		weapon_slot.is_locked = false


var a_modifiers: Array[Modifier]
var b_modifiers: Array[Modifier]

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

@export var current_hp: float = initial_hp:
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

#Dictionary[String,Effect]
var active_effects: Dictionary

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
	if not EventBus.chest_opened.is_connected(on_chest_open):
		EventBus.chest_opened.connect(on_chest_open)
	if not EventBus.chest_closed.is_connected(on_chest_close):
		EventBus.chest_closed.connect(on_chest_close)
	
	#weapon slots
	weapon_slot = weapon_slots.slots[0]
	if not weapon_slot.item_change.is_connected(on_weapon_item_change):
		weapon_slot.item_change.connect(on_weapon_item_change)
	#modifier slots
	connect_modifier_slots(a_modifiers, a_slots, on_a_modifier_item_change)
	connect_modifier_slots(b_modifiers, b_slots, on_b_modifier_item_change)


func connect_modifier_slots(list: Array[Modifier], slots: InventoryGrid, to_call: Callable):
	list.resize(slots.slots.size())
	slots.item_change.connect(to_call)

func on_weapon_item_change(_slot: InventorySlot, from: Item, to: Item):
	#no change
	if from == to:
		return
	#removing weapon
	if not is_instance_valid(to):
		weapon = null
		return
	#not a weapon item
	if not to is WeaponItem:
		push_error("attempt to switch weapon to non weapon item ", to)
		return
	var nto := to as WeaponItem
	#create weapon
	var new_weapon: Node2D = nto.init_node()
	#not actually a weapon
	if not new_weapon is Weapon:
		push_error("attempt to switch weapon to non weapon ", new_weapon)
		if new_weapon: new_weapon.queue_free()
		return
	#equip weapon
	var wnew_weapon := new_weapon as Weapon
	weapon = wnew_weapon

func on_modifier_item_change(slot: InventorySlot, from: Item, to: Item, list: Array[Modifier]):
	var index := slot.j
	
	#no change
	if from == to:
		return
	#removing modifier
	if not is_instance_valid(to):
		if is_instance_valid(list[index]):
			ObjectPool.return_object(list[index])
		list[index] = null
		return
	#not a modifier item
	if not to is ModifierItem:
		push_error("attempt to switch modifier to non modifier item ", to)
		return
	var nto := to as ModifierItem
	#create modifier
	var new_modifier: Node2D = nto.init_node()
	#not actually a modifier
	if not new_modifier is Modifier:
		push_error("attempt to switch modifier to non modifier ", new_modifier)
		if new_modifier: new_modifier.queue_free()
		return
	#equip modifier
	var mnew_modifier := new_modifier as Modifier
	mnew_modifier.modifier_owner = self
	
	add_child(mnew_modifier)
	if is_instance_valid(list[index]):
		ObjectPool.return_object(list[index])
	list[index] = mnew_modifier

func on_a_modifier_item_change(slot: InventorySlot, from: Item, to: Item):
	on_modifier_item_change(slot,from,to,a_modifiers)
func on_b_modifier_item_change(slot: InventorySlot, from: Item, to: Item):
	on_modifier_item_change(slot,from,to,b_modifiers)

func _physics_process(_delta: float) -> void:
	if is_zero_approx(velocity.x): velocity.x = 0
	if is_zero_approx(velocity.y): velocity.y = 0

	if Input.is_action_just_pressed(&"toggle_debug"): debug_active = not debug_active
	debug_label.visible = debug_active
	if debug_active: debug_label.update_text(self)
	
	if Input.is_action_just_pressed(&"inventory_toggle"):
		inventory.toggle()
		#closing inventory. inventories will try and reject the dragged item
		if not inventory.is_open:
			weapon_slots.return_dragged_item()
			a_slots.return_dragged_item()
			b_slots.return_dragged_item()
		

func on_chest_open(_who: Chest) -> void:
	inventory.open()
func on_chest_close(_who: Chest) -> void:
	pass

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
	weapon_slot.is_locked = true
	attack_started.emit()
func _attack_ended() -> void:
	weapon_slot.is_locked = false
	attack_ended.emit()
func _attack_hit(who: Node2D) -> void:
	attack_hit.emit(who)

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
		push_error("trying to apply effect without type: ", effect)
	if not effect.effect_type in active_effects\
	or not is_instance_valid(active_effects[effect.effect_type]):
		active_effects[effect.effect_type] = effect
		add_child(effect)
	active_effects[effect.effect_type].update_with_time(effect.time_left)

func remove_effect(effect: Effect) -> void:
	if effect.effect_type == "":
		push_error("trying to remove effect without type: ", effect)
	if not effect.effect_type in active_effects:
		return
	active_effects.erase(effect.effect_type)
