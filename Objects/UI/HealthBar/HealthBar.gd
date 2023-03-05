extends TextureProgressBar

func _ready() -> void:
	visible = true

func set_health(hp: float) -> void:
	var health_bar_tween := create_tween()
	health_bar_tween.tween_property(self,"value",hp,0.5).from_current()
