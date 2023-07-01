extends Node2D

signal game_closed

const SMALL_WAIT_TIME: float = 0.01
const DAMAGE_POPUP := preload("res://Objects/UI/DamagePopup/DamagePopup.tscn")
const DISABLE_ENEMIES: bool = false

const PHYSICS_LAYERS: Dictionary = {
	collision_map = 1,
	collision_character = 2,
	collision_enemy = 3,
	collision_item = 4,
	
	hitbox_map = 9,
	hitbox_character = 10,
	hitbox_enemy = 11,
	
	hurtbox_map = 17,
	hurtbox_character = 18,
	hurtbox_enemy = 19,
	
	area_interaction = 25
}

var old_window_mode: DisplayServer.WindowMode

var god: bool = false

func _ready() -> void:
	Logger.error("test error")
	Logger.warn("test warning")
	Logger.info("test info")
	Logger.debug("test debug")

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed(&"toggle_god"):
		god = not god
		Logger.info("god" if god else "not god")
	if Input.is_action_just_pressed(&"close_game"):
		game_closed.emit()
		get_tree().quit()
	if Input.is_action_just_pressed(&"toggle_fullscreen"):
		match DisplayServer.window_get_mode():
			DisplayServer.WINDOW_MODE_FULLSCREEN:
				DisplayServer.window_set_mode(old_window_mode)
				old_window_mode = DisplayServer.WINDOW_MODE_MAXIMIZED
			_:
				old_window_mode = DisplayServer.window_get_mode()
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func temp_timer(time: float = SMALL_WAIT_TIME) -> SceneTreeTimer:
	return get_tree().create_timer(time, false, true)

func temp_signal(time: float = SMALL_WAIT_TIME) -> Signal:
	return temp_timer(time).timeout

func schedule_action(action: Callable, time: float = SMALL_WAIT_TIME) -> void:
	temp_signal(time).connect(action)

func schedule_property_change(node: Node, property: StringName, value: Variant, time: float = SMALL_WAIT_TIME) -> void:
	schedule_action(node.set.bind(property,value), time)

func loop_timer(time: float = SMALL_WAIT_TIME) -> Timer:
	var timer := Timer.new()
	timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
	timer.wait_time = time
	timer.autostart = true
	timer.one_shot = false
	return timer

func add_loop_timer(node: Node, time: float = SMALL_WAIT_TIME) -> Timer:
	var timer := loop_timer(time)
	node.add_child(timer)
	return timer

func create_damage_popup(number: float, pos: Vector2) -> void:
	var popup := ObjectPool.load_object(DAMAGE_POPUP)
	popup.value = number
	get_tree().root.add_child(popup)
	popup.global_position = pos
	popup.appear()
