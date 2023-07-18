extends StaticBody2D
class_name Chest

@onready var inventory: Inventory = $UILayer/InventoryGrid
@onready var interact_area: Area2D = $InteractArea
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var provider: LootProvider
var content_loaded: bool = false

var is_open: bool:
	set(value):
		is_open = value
		inventory.is_open = value
		EventBus.chest_toggled.emit(self)
		if is_open:
			EventBus.chest_opened.emit(self)
			animation_player.play(&"open")
			if not content_loaded:
				load_content()
		else:
			EventBus.chest_closed.emit(self)
			animation_player.play(&"close")

func _ready() -> void:
	content_loaded = false
	
	# remove when you know how to not make loot
	# depend on chest opening order
	inventory.ready.connect(load_content)
	
	if not EventBus.chest_opened.is_connected(on_chest_open):
		EventBus.chest_opened.connect(on_chest_open)
	if not interact_area.input_event.is_connected(on_input):
		interact_area.input_event.connect(on_input)

func load_content() -> void:
	if content_loaded:
		return
	if provider:
		inventory.populate_with_provider(Globals.generation_rand, provider)
	content_loaded = true

func _unhandled_input(event: InputEvent) -> void:
	if is_open and event.is_action(&"inventory_toggle"):
		close()

func on_input(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action(&"player_interact") and event.is_pressed():
		HeldItemManager.drop_input_handled = true
		toggle()

func open() -> void:
	is_open = true
func close() -> void:
	is_open = false
func toggle() -> void:
	is_open = not is_open

func on_chest_open(who) -> void:
	if is_open and who != self:
		close()

func pool_cleanup() -> void:
	inventory.pool_cleanup()
