extends Resource
class_name Item

@export var item_name: String
@export var item_category: String
@export var item_stack: int = HeldItemManager.MAX_ITEM_COUNT
@export var texture: Texture2D
@export var extra_info: Dictionary
@export var meta_info: Dictionary
