extends Node2D

var dragged_item: Item:
	set(value):
		if not is_inside_tree():
			await ready
		dragged_item = value
		queue_redraw()
var dragged_item_inventory: Inventory
var dragged_item_slot: InventorySlot

#set of inventories
var open_inventories: Dictionary

var old_window_mode: DisplayServer.WindowMode

func _process(_delta: float) -> void:
	if dragged_item:
		queue_redraw()
	if Input.is_action_just_pressed(&"close_game"):
		get_tree().quit()
	if Input.is_action_just_pressed(&"toggle_fullscreen"):
		match DisplayServer.window_get_mode():
			DisplayServer.WINDOW_MODE_FULLSCREEN:
				DisplayServer.window_set_mode(old_window_mode)
				old_window_mode = DisplayServer.WINDOW_MODE_MAXIMIZED
			_:
				old_window_mode = DisplayServer.window_get_mode()
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func _draw() -> void:
	if not dragged_item: return
	var mouse_pos := get_local_mouse_position()
	draw_texture(dragged_item.texture, mouse_pos)
