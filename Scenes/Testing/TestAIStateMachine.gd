extends "res://Objects/Entity/Enemy/EnemyStateMachine.gd"

const BRAIN := preload("res://Testing/testbrain.tres")
#var display_label := Label.new()
var current_go_dir := Vector2.ZERO

func _ready() -> void:
	super()
	BRAIN.init_weights()
	BRAIN.place_weight("positive", "player", Vector2.ZERO)#navagent.target_position)
	#display_label.theme = load("res://LabelBackgroundTheme.tres")
	#UiLayer.add_child(display_label)

func _state_logic(_delta: float) -> void:
	if enemy.current_hp < 0 and not animation_player.assigned_animation == &"death":
		sprite_effects_player.play(&"death")
		animation_player.play(&"death")
		return

	match state:
		states.idle:
			pass
		states.chase:
			enemy.velocity += ((current_go_dir*enemy.speed)-enemy.velocity)*enemy.acceleration
			enemy.move_and_slide()
		states.hurt:
			enemy.move_and_slide()
			enemy.velocity = enemy.velocity.move_toward(Vector2.ZERO, enemy.stun_friction)

func _on_PathfindingTimer_timeout() -> void:
	if not is_instance_valid(chase_target): return
	#navagent.target_position = chase_target.global_position
	BRAIN.move_weight("positive", "player", chase_target.global_position)
	var dir = BRAIN.get_best(enemy.global_position)
	#display_label.text = str(dir) + "\n" + str(enemy.global_position.distance_to(chase_target.global_position))
	current_go_dir = current_go_dir.lerp(dir, 0.4)
