extends TextureProgress

onready var health_bar_tween: Tween = $HealthBarTween

func _ready() -> void:
	visible = true

func set_health(hp: float) -> void:
	var _unused = health_bar_tween.interpolate_property(self,
		"value", value, hp, 0.5,
		Tween.TRANS_QUINT, Tween.EASE_OUT)
	_unused = health_bar_tween.start()
