extends CollisionObject2D
class_name DroppedItem

@onready var sprite := $Sprite
@onready var collision := $Collision
@onready var animation_player := $AnimationPlayer
@onready var info_label := $InfoLabelBase/InfoLabel
@onready var info_label_base := $InfoLabelBase

var appear_tween: Tween = null
var disappear_tween: Tween = null

const APPEAR_MOVEMENT := Vector2(0,-30)
const APPEAR_COLOR := Color(1,1,1,0.7)
const APPEAR_TIME := 0.5
const DISAPPEAR_TIME := 0.3
const DISAPPEAR_DELAY := 0.5

func _ready() -> void:
	pass

func _mouse_enter() -> void:
	#kill current tweens if exist
	if disappear_tween and disappear_tween.is_valid():
		disappear_tween.kill()
	if appear_tween and appear_tween.is_valid():
		appear_tween.kill()
	
	#create new tween
	appear_tween = create_tween().set_parallel(true)
	#tween the position and modulate
	appear_tween\
		.tween_property(info_label_base, "position", APPEAR_MOVEMENT, APPEAR_TIME)\
		.from_current().set_trans(Tween.TRANS_QUINT)
	appear_tween\
		.tween_property(info_label, "modulate", APPEAR_COLOR, APPEAR_TIME)\
		.from_current().set_trans(Tween.TRANS_QUINT)

func _mouse_exit() -> void:
	#wait until popup up
	if appear_tween and appear_tween.is_valid(): await appear_tween.finished
	
	#create tween
	disappear_tween = create_tween().set_parallel(true)
	#tween the position and modulate
	disappear_tween\
		.tween_property(info_label_base, "position", Vector2.ZERO, DISAPPEAR_TIME)\
		.from_current().set_delay(DISAPPEAR_DELAY).set_trans(Tween.TRANS_QUAD)
	disappear_tween\
		.tween_property(info_label, "modulate", Color(1,1,1,0), DISAPPEAR_TIME)\
		.from_current().set_delay(DISAPPEAR_DELAY).set_trans(Tween.TRANS_QUAD)
		

func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if not event.is_action(&"player_pickup"): return
	print("picked me up uwu")
