extends StateMachine

var enemy: Enemy
@onready var animation_player: AnimationPlayer = $"../AnimationPlayer"
@onready var sprite_effects_player: AnimationPlayer = $"../Sprite/SpriteEffectPlayer"
@onready var navagent : NavigationAgent2D = $"../NavAgent"
@onready var hurtbox: Hurtbox = $"../Hurtbox"
@onready var hitbox: Hitbox = $"../Hitbox"
var chase_target: Node2D = null

func _init():
	_add_state("idle")
	_add_state("chase")
	_add_state("hurt")

func _ready() -> void:
	enemy = parent
	set_state(states.idle)

func _state_logic(_delta: float) -> void:
	if Globals.DISABLE_ENEMIES: return
	if enemy.current_hp < 0 and not animation_player.assigned_animation == &"death":
		sprite_effects_player.play(&"death")
		animation_player.play(&"death")
		return

	match state:
		states.idle:
			pass
		states.chase:
			var dir = enemy.global_position.direction_to(navagent.get_next_path_position())
			enemy.velocity += ((dir*enemy.speed)-enemy.velocity)*enemy.acceleration
			enemy.move_and_slide()
		states.hurt:
			enemy.move_and_slide()
			enemy.velocity = enemy.velocity.move_toward(Vector2.ZERO, enemy.stun_friction)

func _get_transition() -> int:
	match state:
		states.idle:
			if is_instance_valid(chase_target):
				return states.chase
		states.chase:
			if \
				not is_instance_valid(chase_target) and \
				(navagent.is_navigation_finished() or \
				not navagent.is_target_reachable()):
				return states.idle
	return -1

func _exit_state(_state_exited: int) -> void:
	match _state_exited:
		states.hurt:
			sprite_effects_player.play(&"RESET")
			sprite_effects_player.advance(0)
			sprite_effects_player.stop()

func _enter_state(_prev_state: int, _state: int) -> void:
	match _state:
		states.hurt:
			sprite_effects_player.play(&"hurt")
			animation_player.play(&"hurt")

func _on_ChaseRange_body_entered(_body: Node) -> void:
	chase_target = _body
func _on_ChaseRange_body_exited(_body: Node) -> void:
	if chase_target == _body: chase_target = null

func _on_PathfindingTimer_timeout() -> void:
	if not is_instance_valid(chase_target): return
	navagent.target_position = chase_target.global_position

#got a hit
func _on_EnemyHitbox_area_entered(area: Area2D) -> void:
	if not area is Hurtbox: return
	var _hurtbox = area as Hurtbox
	enemy.velocity *= enemy.on_hit_velocity_mult

#got hit
func _on_EnemyHurtbox_area_entered(area: Area2D) -> void:
	if not area is Hitbox: return
	enemy.apply_hit(area)

func _on_InvincibilityTimer_timeout() -> void:
	hurtbox.active = true

func _on_EnemyAnimationPlayer_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		&"hurt":
			set_state(states.idle)
		&"death":
			enemy.queue_free()
