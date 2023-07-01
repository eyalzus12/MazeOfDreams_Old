extends Resource
class_name InventoryItem

const NUMBER_FONT := preload("res://CONSOLA.TTF")

@export var item: Item:
	get:
		if count == 0:
			return null
		return item
@export var count: int = 0:
	set(value):
		if value == 0:
			item = null
		count = value

func draw(canvas_item: CanvasItem, position: Vector2) -> void:
	if not item:
		return
	canvas_item.draw_texture(item.texture, position)
	canvas_item.draw_string(NUMBER_FONT, position, str(count))
