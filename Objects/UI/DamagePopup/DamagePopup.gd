extends Node2D

const SPAWN_DEVIATION: float = 50

@onready var label: Label = $LabelBase/DamageLabel
@onready var player: AnimationPlayer = $LabelBase/DamageLabel/DamageLabelPlayer

var value: float:
	set(f):
		value = f
		if not is_inside_tree(): await ready
		label.text = str(round(f))
		match int(sign(f)):
			1: #positive
				modulate = Color.GREEN
			-1: #negative
				modulate = Color.RED
			0: #none
				modulate = Color.BLUE

func _ready() -> void:
	player.play(&"RESET")
	player.advance(0)

func appear() -> void:
	player.play("appear")
	
	#slightly randomize spawn position
	position = position + Vector2(
		randf_range(-SPAWN_DEVIATION,SPAWN_DEVIATION),
		randf_range(-SPAWN_DEVIATION,SPAWN_DEVIATION)
	)

func disappear() -> void:
	ObjectPool.return_object(self)
