extends Node2D
class_name Trap

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var trap_groups: Array = []

var body_count: int = 0

func _on_DetectionRange_body_entered(_body: Node) -> void:
	get_tree().call_group(&"traps", &"body_enter_for", trap_groups)
func _on_DetectionRange_body_exited(_body: Node) -> void:
	get_tree().call_group(&"traps", &"body_leave_for", trap_groups)

func group_with(groups: Array) -> bool:
	for group in groups:
		if group in trap_groups:
			return true
	return false

func body_enter_for(groups: Array) -> void:
	if not group_with(groups): return
	
	body_count += 1
	if body_count == 1: activate()
	
func body_leave_for(groups: Array) -> void:
	if not group_with(groups): return
	
	body_count -= 1
	if body_count == 0: deactivate()

func activate() -> void:
	animation_player.clear_queue()
	animation_player.queue(&"activate")
	animation_player.queue(&"deactivate")

func deactivate() -> void:
	animation_player.clear_queue()
	animation_player.queue(&"deactivate")
