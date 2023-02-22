extends StateMachine

const DamagePopup := preload("res://Scenes/Objects/DamagePopup.tscn")

onready var animation_player: AnimationPlayer = $"../AnimationPlayer"
onready var sprite_effects_player: AnimationPlayer = $"../Sprite/SpriteEffectPlayer"
onready var sword: Sword = $"../Sword"
onready var character: Character = parent as Character
onready var hurtbox: Hurtbox = $"../Hurtbox"

func _init() -> void:
	_add_state("idle")
	_add_state("move")
	_add_state("dash")
	_add_state("hurt")

func _ready() -> void:
	set_state(states.idle)

func _state_logic(_delta: float) -> void:
	character.state_frame = state_frame
	character.current_state = state_names[state]
	character.set_inputs()
	
	if character.current_hp < 0:
		sprite_effects_player.play("death")
		animation_player.play("death")
		return
	
	if not state in [states.hurt] and not sword.is_attacking:
		if Input.is_action_just_pressed("player_attack"): sword.attack()
		character.set_direction()
	
	match state:
		states.idle, states.move:
			var _unused = character.move_and_slide(character.velocity)
			if character.is_on_wall():
				var col = character.get_slide_collision(0)
				var grazing = is_zero_approx(col.normal.dot(character.velocity))
				if character.in_dash and not grazing:
					character.velocity = character.velocity.bounce(col.normal)
					character.velocity *= character.dash_bounce_mult
			continue
		states.idle:
			character.velocity = character.velocity.move_toward( \
				Vector2.ZERO, character.acceleration)
		states.move:
			character.velocity = character.velocity.move_toward( \
				character.speed*character.velocity_vector, \
				character.acceleration)
		states.dash:
			var dashAcceleration: float = character.dash_speed/ceil(character.dash_startup)
			character.velocity = character.velocity.move_toward( \
				character.dash_speed*character.velocity_vector, \
				dashAcceleration)
			var _unused = character.move_and_slide(character.velocity)
		states.hurt:
			var _unused = character.move_and_slide(character.velocity)
			character.velocity = character.velocity.move_toward(Vector2.ZERO, character.stun_friction)

func _get_transition() -> int:
	match state:
		states.idle:
			if character.input_vector != Vector2.ZERO:
				return states.move
		states.move:
			if !character.dash_in_cooldown and Input.is_action_just_pressed("player_dash"):
				return states.dash
			if character.input_vector == Vector2.ZERO:
				return states.idle
		states.dash:
			if state_frame > ceil(character.dash_startup):
				return states.move
	return -1

func _exit_state(_state_exited: int) -> void:
	match _state_exited:
		states.dash:
			character.dash_in_cooldown = true;
			character.dash_cooldown_timer.start()
			character.in_dash = true
			character.in_dash_timer.start()
		states.hurt:
			sprite_effects_player.play("RESET")
			sprite_effects_player.advance(0)
			sprite_effects_player.stop(true)

func _enter_state(_prev_state: int, _state: int) -> void:
	match _state:
		states.hurt:
			sprite_effects_player.play("hurt")
			animation_player.play("hurt")

#got hit
func _on_CharacterHurtbox_area_entered(area: Area2D) -> void:
	if not area is Hitbox: return
	var hitbox = area as Hitbox
	character.current_hp -= hitbox.damage
	character.velocity = hitbox.global_position \
		.direction_to(character.global_position) \
		* hitbox.pushback
	set_state(states.hurt)
	
	var popup := DamagePopup.instance()
	popup.value = -hitbox.damage
	get_tree().root.add_child(popup)
	popup.global_position = character.global_position
	popup.appear()

#finished animation
func _on_CharacterAnimationPlayer_animation_finished(anim_name: String) -> void:
	match anim_name:
		"hurt":
			set_state(states.idle)
		"death":
			character.queue_free()

func _on_InvincibilityTimer_timeout() -> void:
	hurtbox.active = true
