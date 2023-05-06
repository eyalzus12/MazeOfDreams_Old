extends CollisionObject2D
class_name DroppedItem

@export var item: Item:
	set(value):
		item = value
		if not item:
			return
		if not is_inside_tree():
			await ready
		sprite.texture = item.texture
		info_label.text = item.item_name
		#hack to get label to properly resize
		info_label.size = Vector2.ZERO

@onready var sprite: Sprite2D = $Sprite
@onready var collision: CollisionShape2D = $Collision
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var info_label: Label = $InfoLabelBase/InfoLabel
@onready var info_label_base: Control = $InfoLabelBase
@onready var pickup_area: Area2D = $PickupArea

var label_offset: Vector2 = Vector2(NAN,NAN)

var appear_tween: Tween = null
var visible_goal: bool = false
var disappear_tween: Tween = null

const APPEAR_MOVEMENT := Vector2(0,-30)
const APPEAR_COLOR := Color(1,1,1,0.7)
const APPEAR_TIME := 0.5
const DISAPPEAR_TIME := 0.3
const DISAPPEAR_DELAY := 0.5

func pool_setup() -> void:
	label_offset = Vector2(NAN,NAN)
	
	if appear_tween: appear_tween.kill()
	appear_tween = null
	if disappear_tween: disappear_tween.kill()
	disappear_tween = null
	visible_goal = false
	
	if info_label:
		info_label.text = ""
		info_label.size = Vector2.ZERO
		info_label_base.modulate = Color.TRANSPARENT

func _ready() -> void:
	if not pickup_area.mouse_entered.is_connected(mouse_enter):
		pickup_area.mouse_entered.connect(mouse_enter)
	if not pickup_area.mouse_exited.is_connected(mouse_exit):
		pickup_area.mouse_exited.connect(mouse_exit)
	if not pickup_area.input_event.is_connected(on_input):
		pickup_area.input_event.connect(on_input)

func _process(_delta: float) -> void:
	if is_nan(label_offset.x):
		label_offset = info_label.position
		info_label.position = Vector2.ZERO
	info_label_base.global_position = global_position + label_offset

func mouse_enter() -> void:
	visible_goal = true
	#kill current tweens if exist
	if disappear_tween and disappear_tween.is_valid():
		disappear_tween.kill()
	if appear_tween and appear_tween.is_running():
		return

	#create new tween
	appear_tween = create_tween().set_parallel(true)
	#tween the position and modulate
	appear_tween\
		.tween_property(info_label, ^"position", APPEAR_MOVEMENT, APPEAR_TIME)\
		.from_current().set_trans(Tween.TRANS_QUINT)
	appear_tween\
		.tween_property(info_label_base, ^"modulate", APPEAR_COLOR, APPEAR_TIME)\
		.from_current().set_trans(Tween.TRANS_QUINT)

func mouse_exit() -> void:
	visible_goal = false
	#wait until popup up
	if appear_tween and appear_tween.is_valid(): await appear_tween.finished
	if visible_goal: return
	
	#create tween
	disappear_tween = create_tween().set_parallel(true)
	#tween the position and modulate
	disappear_tween\
		.tween_property(info_label, ^"position", Vector2.ZERO, DISAPPEAR_TIME)\
		.from_current().set_delay(DISAPPEAR_DELAY).set_trans(Tween.TRANS_QUAD)
	disappear_tween\
		.tween_property(info_label_base, ^"modulate", Color.TRANSPARENT, DISAPPEAR_TIME)\
		.from_current().set_delay(DISAPPEAR_DELAY).set_trans(Tween.TRANS_QUAD)


func on_input(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if not event.is_action(&"player_interact") or not event.is_pressed(): return
	if not item: return
	
	for inventory_ in Globals.inventories:
		var inventory: Inventory = inventory_
		if not inventory.pickup_target: continue
		var inserted: bool = inventory.try_insert(item)
		if inserted:
			ObjectPool.return_object(self)
			return

