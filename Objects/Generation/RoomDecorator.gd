extends Node2D
class_name RoomDecorator

signal room_decoration_finished()

var rand: Random
var positions: PackedVector2Array
var shapes: Array[Shape2D]
var tilemap: TileMapExtensions
var floor_layer: int:
	get: return tilemap.get_layer_by_name("floors")
var wall_layer: int:
	get: return tilemap.get_layer_by_name("walls")
var enemy_layer: int:
	get: return tilemap.get_layer_by_name("enemies")
var maze_source: int:
	get: return tilemap.get_source_by_name("Maze")
var enemies_source: int:
	get: return tilemap.get_source_by_name("Enemies")
var enemies_tile: int:
	get: return 0#tilemap.get_scene_tile_by_name(enemies_source, "Enemy")

func init_decorating() -> void:
	#put 1 enemy in every room
	for i in range(positions.size()):
		var pos := positions[i]
		var shape := shapes[i]
		var topleft: Vector2 = pos - shape.size/2.
		var bottomright: Vector2 = pos + shape.size/2. - tilemap.tile_set.tile_size/1.
		var topleftmap: Vector2i = tilemap.global_to_map(topleft)+Vector2i.ONE
		var bottomrightmap: Vector2i = tilemap.global_to_map(bottomright)-Vector2i.ONE
		var spawnloc: Vector2i = rand.random_point_in_Rect2i(topleftmap, bottomrightmap)
		tilemap.set_cell(enemy_layer, spawnloc, enemies_source, Vector2i.ZERO, enemies_tile)
	room_decoration_finished.emit()
