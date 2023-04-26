extends StaticBody2D
class_name Chest

@onready var inventory: Inventory = $UILayer/InventoryGrid
@onready var interact_area: Area2D = $InteractArea
var is_open: bool:
	set(value):
		is_open = value
		inventory.is_open = value
		EventBus.emit_signal("chest_toggled", self)
		if is_open: EventBus.emit_signal("chest_opened", self)
		else: EventBus.emit_signal("chest_closed", self)

func _ready() -> void:
	EventBus.chest_opened.connect(on_chest_open)
	interact_area.input_event.connect(on_input)

func _unhandled_input(event: InputEvent) -> void:
	if is_open and event.is_action(&"inventory_toggle"):
		close()

func on_input(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action(&"player_interact") and event.is_pressed():
		Globals.drop_input_handled = true
		toggle()

func open() -> void:
	is_open = true
func close() -> void:
	is_open = false
func toggle() -> void:
	is_open = not is_open

func on_chest_open(who) -> void:
	if who != self:
		close()
