extends TextureProgressBar

var health_bar_tween: Tween

func _ready() -> void:
	visible = true

func set_health(hp: float) -> void:
	if health_bar_tween and health_bar_tween.is_valid():
		health_bar_tween.kill()
	
	health_bar_tween = create_tween()
	health_bar_tween.tween_property(self,"value",hp,0.5).from_current().set_trans(Tween.TRANS_QUINT)
