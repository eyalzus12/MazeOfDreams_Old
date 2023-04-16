extends Node2D

var dragged_item: Item:
	set(value):
		if not is_inside_tree():
			await ready
		dragged_item = value
		queue_redraw()
var dragged_item_slot: InventorySlot

func _process(_delta: float) -> void:
	if dragged_item:
		queue_redraw()

func _draw() -> void:
	if not dragged_item: return
	var mouse_pos := get_local_mouse_position()
	draw_texture(dragged_item.texture, mouse_pos)
