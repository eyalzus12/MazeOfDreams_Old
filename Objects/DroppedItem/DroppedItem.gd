extends CollisionObject2D
class_name DroppedItem

@onready var sprite := $Sprite
@onready var collision := $Collision
@onready var animation_player := $AnimationPlayer
@onready var info_label := $InfoLabelBase/InfoLabel
@onready var info_label_base := $InfoLabelBase
@onready var pickup_area := $PickupArea

var label_offset: Vector2 = Vector2(NAN,NAN)

var appear_tween: Tween = null
var disappear_tween: Tween = null

const APPEAR_MOVEMENT := Vector2(0,-30)
const APPEAR_COLOR := Color(1,1,1,0.7)
const APPEAR_TIME := 0.5
const DISAPPEAR_TIME := 0.3
const DISAPPEAR_DELAY := 0.5

func _ready() -> void:
	pickup_area.mouse_entered.connect(mouse_enter)
	pickup_area.mouse_exited.connect(mouse_exit)
	pickup_area.input_event.connect(on_input)

func _process(_delta: float) -> void:
	if is_nan(label_offset.x): label_offset = info_label.position
	info_label_base.global_position = global_position + label_offset

func mouse_enter() -> void:
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
	#wait until popup up
	if appear_tween and appear_tween.is_valid(): await appear_tween.finished

	#create tween
	disappear_tween = create_tween().set_parallel(true)
	#tween the position and modulate
	disappear_tween\
		.tween_property(info_label, ^"position", Vector2.ZERO, DISAPPEAR_TIME)\
		.from_current().set_delay(DISAPPEAR_DELAY).set_trans(Tween.TRANS_QUAD)
	disappear_tween\
		.tween_property(info_label_base, ^"modulate", Color(1,1,1,0), DISAPPEAR_TIME)\
		.from_current().set_delay(DISAPPEAR_DELAY).set_trans(Tween.TRANS_QUAD)


func on_input(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if not event.is_action(&"player_pickup"): return
	print("picked me up uwu")

