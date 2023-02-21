extends Node
class_name StateMachine

var states: Dictionary = {}
var state_names: Dictionary = {}
var prev_state: int = -1
var state: int = -1 setget set_state
var state_frame: int = 0

onready var parent: Node2D = get_parent()

func _physics_process(delta: float) -> void:
	if state != -1:
		_state_logic(delta)
		var transition = _get_transition()
		if transition != -1: set_state(transition)
	state_frame += 1

func _state_logic(_delta: float) -> void:
	pass

func _get_transition() -> int:
	return -1

func _add_state(new_state: String) -> void:
	states[new_state] = states.size();
	state_names[states[new_state]] = new_state

func set_state(new_state: int) -> void:
	_exit_state(state)
	prev_state = state
	state = new_state
	_enter_state(prev_state, state)
	state_frame = 0

func _exit_state(_state_exited: int) -> void:
	pass

func _enter_state(_prev_state: int, _state: int) -> void:
	pass
