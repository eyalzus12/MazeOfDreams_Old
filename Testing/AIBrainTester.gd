extends Node2D

@export var brain: AIBrain

var positives: Array[Vector2] = []
var negatives: Array[Vector2] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	brain.init_weights()
	brain.place_weight("positive", "test", Vector2.ZERO)
	positives.append(Vector2.ZERO)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("player_attack"):
		var mouse := get_local_mouse_position()
		brain.move_weight("positive", "test", mouse)
		positives[0] = mouse
		queue_redraw()
	if Input.is_action_just_pressed("player_pickup"):
		var mouse := get_local_mouse_position()
		brain.place_weight("negative", str(negatives.size()), mouse)
		negatives.append(mouse)
		queue_redraw()

func _draw() -> void:
	for positive in positives:
		draw_circle(positive, 5, Color.GREEN)
	for negative in negatives:
		draw_circle(negative, 5, Color.RED)
	var dir := Vector2.ZERO
	for i in range(100):
		var actual := remap(i, 0, 100, 0, TAU)
		var vec := Vector2.from_angle(actual)
		var score := brain.get_total_score(Vector2.ZERO, vec)
		dir += score*vec
		if score > 0:
			draw_line(Vector2.ZERO, 500*vec*score, Color.GREEN)
		elif score < 0:
			draw_line(Vector2.ZERO, 500*vec*-score, Color.RED)
	
	draw_line(Vector2.ZERO, 700*dir.normalized(), Color.BLUE)
