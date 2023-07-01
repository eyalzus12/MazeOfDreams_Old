extends TileMap
class_name TileMapExtensions

var layer_name_cache: Dictionary = {}
var source_name_cache: Dictionary = {}
#Dictionary[int, Dictionary[string, int]]
#var scene_tile_name_cache: Dictionary = {}

func _ready() -> void:
	cache_all_layers()
	cache_all_sources()
	#cache_scene_tiles_for_all_sources()

func global_to_map(global_point: Vector2) -> Vector2i:
	return local_to_map(to_local(global_point))
func map_to_global(map_position: Vector2i) -> Vector2:
	return to_global(map_to_local(map_position))

func cache_all_layers() -> void:
	for i in range(get_layers_count()):
		layer_name_cache[get_layer_name(i)] = i
func reload_layer_cache() -> void:
	layer_name_cache.clear()
func get_layer_by_name(layer_name: String) -> int:
	if layer_name in layer_name_cache:
		return layer_name_cache[layer_name]
	for i in range(get_layers_count()):
		if layer_name == get_layer_name(i):
			layer_name_cache[layer_name] = i
			return i
	Logger.error(str("could not find layer name ",layer_name," in tilemap ",self))
	return -1

func cache_all_sources() -> void:
	for i in range(tile_set.get_source_count()):
		var id := tile_set.get_source_id(i)
		source_name_cache[tile_set.get_source(id).resource_name] = id
func clear_source_cache() -> void:
	source_name_cache.clear()
func get_source_by_name(source_name: String) -> int:
	if source_name in source_name_cache:
		return source_name_cache[source_name]
	for i in range(tile_set.get_source_count()):
		var id := tile_set.get_source_id(i)
		if source_name == tile_set.get_source(id).resource_name:
			source_name_cache[source_name] = id
			return id
	Logger.error(str("could not find source name ",source_name," in tilemap ",self))
	return -1

#func cache_scene_tiles_for_all_sources() -> void:
#	for i in range(tile_set.get_source_count()):
#		var id := tile_set.get_source_id(i)
#		if tile_set.get_source(id) is TileSetScenesCollectionSource:
#			cache_scene_tiles_for_source(id)
#func cache_scene_tiles_for_source(source_id: int) -> void:
#	var source := tile_set.get_source(source_id)
#	if not source is TileSetScenesCollectionSource:
#		push_error("attempt to cache scene tiles for non scene tile source ", source_id, " at tilemap ", self)
#		return
#	var scene_source := source as TileSetScenesCollectionSource
#	for i in range(scene_source.get_scene_tiles_count()):
#		var tile_id := scene_source.get_scene_tile_id(i)
#		var tile_scene := scene_source.get_scene_tile_scene(tile_id)
#		var tile_name := tile_scene.resource_name
#		if not source_id in scene_tile_name_cache:
#			scene_tile_name_cache[source_id] = {}
#		scene_tile_name_cache[source_id][tile_name] = tile_id
#func reload_scene_tile_cache() -> void:
#	scene_tile_name_cache.clear()
#func get_scene_tile_by_name(source_id: int, tile_name: String) -> int:
#	if source_id in scene_tile_name_cache and tile_name in scene_tile_name_cache[source_id]:
#		return scene_tile_name_cache[source_id][tile_name]
#	var source := tile_set.get_source(source_id)
#	if not source is TileSetScenesCollectionSource:
#		push_error("attempt to get scene tile for non scene tile source ", source_id, " at tilemap ", self)
#		return -1
#	var scene_source := source as TileSetScenesCollectionSource
#	for i in range(scene_source.get_scene_tiles_count()):
#		var tile_id := scene_source.get_scene_tile_id(i)
#		var tile_scene := scene_source.get_scene_tile_scene(tile_id)
#		if tile_name == tile_scene.resource_name:
#			if not source_id in scene_tile_name_cache:
#				scene_tile_name_cache[source_id] = {}
#			scene_tile_name_cache[source_id][tile_name] = tile_id
#			return tile_id
#	push_error("could not find scene tile name ",tile_name," in tileset source ",source_id," in tilemap ",self)
#	return -1

#TODO: add such methods for terrains and other layer types
