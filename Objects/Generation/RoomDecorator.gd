extends Node2D
class_name RoomDecorator

signal room_decoration_finished()

const CHEST := preload("res://Objects/Chest/Chest.tscn")

var rand: Random
var positions: PackedVector2Array
var shapes: Array[Shape2D]
var tilemap: TileMapExtensions

@export var test_provider: LootProvider

var floor_layer: int:
	get: return tilemap.get_layer_by_name("floors")
var wall_layer: int:
	get: return tilemap.get_layer_by_name("walls")
var enemy_layer: int:
	get: return tilemap.get_layer_by_name("enemies")
var chest_layer: int:
	get: return tilemap.get_layer_by_name("chests")

var maze_source: int:
	get: return tilemap.get_source_by_name("Maze")
var enemies_source: int:
	get: return tilemap.get_source_by_name("Enemies")
var chests_source: int:
	get: return tilemap.get_source_by_name("Chests")

var enemies_tile: int:
	get: return 0#tilemap.get_scene_tile_by_name(enemies_source, "Enemy")
var chest_tile: int:
	get: return 1#tilemap.get_scene_tile_by_name(chests_source, "Chest")

func init_decorating() -> void:
	#put 1 enemy in every room
	Logger.logs("decorating enemies")
	decorate_enemies()
	Logger.logs("finished decorating enemies")
	#put 1 chest in each room at probability 0.3
	Logger.logs("decorating chests")
	decorate_chests()
	Logger.logs("finished decorating chests")
	
	room_decoration_finished.emit()

func decorate_enemies() -> void:
	for i in range(positions.size()):
		var pos := positions[i]
		var shape := shapes[i]
		var topleft: Vector2 = pos - shape.size/2.
		var bottomright: Vector2 = pos + shape.size/2. - tilemap.tile_set.tile_size/1.
		var topleftmap: Vector2i = tilemap.global_to_map(topleft)+Vector2i.ONE
		var bottomrightmap: Vector2i = tilemap.global_to_map(bottomright)-Vector2i.ONE
		var spawnloc: Vector2i = rand.random_point_in_Rect2i(topleftmap, bottomrightmap)
		tilemap.set_cell(enemy_layer, spawnloc, enemies_source, Vector2i.ZERO, enemies_tile)

func decorate_chests() -> void:
	#load ahead of time the approximate numer of needed chests
	ObjectPool.pool_load_object(CHEST, ceil(positions.size()*0.3))
	
	for i in range(positions.size()):
		if rand.chance(0.3):
			var pos := positions[i]
			var shape := shapes[i]
			var topleft: Vector2 = pos - shape.size/2.
			var bottomright: Vector2 = pos + shape.size/2. - tilemap.tile_set.tile_size/1.
			var topleftmap: Vector2i = tilemap.global_to_map(topleft)+Vector2i.ONE
			var bottomrightmap: Vector2i = tilemap.global_to_map(bottomright)-Vector2i.ONE
			var placelocmap: Vector2i = rand.random_point_in_Rect2i(topleftmap, bottomrightmap)
			var placeloc: Vector2 = tilemap.map_to_global(placelocmap)
			var chest: Chest = ObjectPool.load_object(CHEST)
			chest.name = str("chest",i)
			chest.global_position = placeloc
			chest.provider = test_provider
			get_tree().root.add_child(chest)
