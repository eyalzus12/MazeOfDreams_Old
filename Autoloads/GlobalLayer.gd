extends CanvasLayer

func display(s: String) -> void:
	var label := Label.new()
	label.text = s
	var label_tween = create_tween()
	label_tween.tween_property(label, ^"modulate", Color.TRANSPARENT, 0.5).from(Color.WHITE)
	label_tween.tween_callback(label.queue_free)
	add_child(label)
