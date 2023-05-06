extends Effect

@export var fire_interval: float
@export var fire_damage: float

@onready var fire_timer: Timer = $FireTimer

func get_effect_type() -> String:
	var super_effect_type = super.get_effect_type()
	if super_effect_type != "": return super_effect_type
	return "Fire"

func _ready() -> void:
	super._ready()
	effect_type = "Fire"
	fire_timer.start(fire_interval)

func _on_fire_timer_timeout() -> void:
	if effect_owner and effect_owner.has_method(&"apply_damage"):
		effect_owner.apply_damage(fire_damage)
