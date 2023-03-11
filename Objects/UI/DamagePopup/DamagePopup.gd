extends Node2D

@onready var label: Label = $LabelBase/DamageLabel
@onready var player: AnimationPlayer = $LabelBase/DamageLabel/DamageLabelPlayer

var value: float : set = set_value

func appear() -> void:
	player.play("appear")

func _ready() -> void:
	set_value(value)

func set_value(f: float) -> void:
	value = f
	if not is_inside_tree(): return
	label.text = str(round(f))
	match int(sign(f)):
		1: #positive
			modulate = Color.GREEN
		-1: #negative
			modulate = Color.RED
		0: #none
			modulate = Color.WHITE
