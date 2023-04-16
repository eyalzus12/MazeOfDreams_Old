extends Resource
class_name ItemModifierCollection

var modifiers_np: Array[NodePath]
var modifiers: Dictionary
var entity: Node2D

func _init(entity_: Node2D, modifiers_np_: Array[NodePath]) -> void:
	modifiers.clear()
	modifiers_np = modifiers_np_
	entity = entity_
	for modifier_np in modifiers_np:
		var modifier := entity.get_node(modifier_np)
		add(modifier)
		

func add(modifier: ItemModifier) -> void:
	modifier.entity = entity
	modifiers[modifier] = null

func remove(modifier: ItemModifier) -> void:
	modifiers.erase(modifier)

func has(modifier: ItemModifier) -> bool:
	return modifiers.has(modifier)

func get_modifiers() -> Array:
	return modifiers.keys()
