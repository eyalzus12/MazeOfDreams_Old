extends Node2D
class_name RoomDreamer

const ROOM_SHAPE := preload("res://Objects/Generation/RoomShape.tscn")
const DEBUG_DRAW := true

signal room_dreaming_finished(positions: PackedVector2Array, shapes: Array[Shape2D])

@export var starting_room_shape: PackedScene = preload("res://Objects/Generation/RoomShape.tscn")
@export var generated_room_amount: int = 100
@export var min_room_size: int = 6
@export var max_room_size: int = 18
@export var big_room_start: int = 216
@export var placement_radius: float = 40
@export var hallway_width: int = 2

@export var max_spread_wait: float = 5
@export var spread_finish_check_interval: float = 0.05

var tilemap: TileMapExtensions
var tileset: TileSet:
	get:
		return tilemap.tile_set
var floor_layer: int:
	get: return tilemap.get_layer_by_name("floors")
var wall_layer: int:
	get: return tilemap.get_layer_by_name("walls")
var enemy_layer: int:
	get: return tilemap.get_layer_by_name("enemies")
var maze_source: int:
	get: return tilemap.get_source_by_name("Maze")

var finished: bool = false
var finished_placing: bool = false
var rand: Random
var room_list: Array[RoomShape] = []
var big_room_list: Array[RoomShape] = []
var room_edge_list: Array[ConnectionEdge] = []
var mst_edge_list: Array[ConnectionEdge] = []
var hallways_list: Array[HallwaySegment] = []
var final_room_list: Array[RoomShape] = []
var final_positions: PackedVector2Array = []
var final_shapes: Array[Shape2D] = []

var hallway_intersections_list: Array[Vector2i] = []

var backup_wall_cord_set: Dictionary = {}
var backup_floor_cord_set: Dictionary = {}

var temp_wall_cord_set: Dictionary = {}
var temp_floor_cord_set: Dictionary = {}

var wall_cord_set: Dictionary = {}
var floor_cord_set: Dictionary = {}

var room_tile_set: Dictionary = {}

var check_timer: Timer
var timeout_timer: SceneTreeTimer

func create_random_room() -> RoomShape:
	var room_shape: RoomShape = ObjectPool.load_object(ROOM_SHAPE)
	var collision_shape := RectangleShape2D.new()
	collision_shape.size = 2.*tileset.tile_size*Vector2(
		rand.randi_range(min_room_size, max_room_size),
		rand.randi_range(min_room_size, max_room_size)
	)
	collision_shape.custom_solver_bias = 1
	var room_shape_collision: CollisionShape2D = room_shape.get_node(^"RoomShapeCollision")
	room_shape_collision.shape = collision_shape
	
	return room_shape

func place_room(room: RoomShape) -> void:
	var pos := rand.random_point_in_circle(placement_radius)
	room.global_position = pos
	room_list.append(room)
	get_tree().root.add_child.call_deferred(room)

func create_and_place_rooms() -> void:
	for i in range(generated_room_amount):
		var room := create_random_room()
		room.name = str("room", i)
		place_room(room)

func init_spread() -> void:
	Logger.logs("room spreading starting")
	finished = false
	finished_placing = false
	
	draw_edges_flag = false
	draw_big_flag = false
	draw_mst_flag = false
	draw_hallways_flag = false
	draw_final_flag = false
	use_final_shapes = false
	create_and_place_rooms()
	timeout_timer = Globals.temp_timer(max_spread_wait)
	timeout_timer.timeout.connect(spread_timeout)
	check_timer = Globals.add_loop_timer(self, spread_finish_check_interval)
	check_timer.timeout.connect(check_spread_finish)
	Engine.physics_ticks_per_second = 300
	Engine.max_physics_steps_per_frame = 60
	Engine.physics_jitter_fix = 0

func spread_timeout() -> void:
	Logger.logs("spread timeout reached")
	check_spread_finish()
	if finished: return
	Logger.error(str("spreading took too long. report seed ",rand.given_seed," to cheese"))
	finish_spread()

func check_spread_finish() -> void:
	if finished: return
	for room in room_list:
		room.global_position = room.global_position.snapped(tileset.tile_size)
	await get_tree().physics_frame
	#failsafe for race condition
	if finished: return
	for room in room_list:
		if not room.sleeping:
			return
	finished = true
	finish_spread()

func finish_spread() -> void:
	Logger.logs("finished spread")
	Engine.physics_ticks_per_second = 60
	Engine.max_physics_steps_per_frame = 8
	Engine.physics_jitter_fix = 0.5
	check_timer.queue_free()
	timeout_timer.timeout.disconnect(spread_timeout)
	timeout_timer = null
	for room in room_list:
		room.global_position = room.global_position.snapped(tileset.tile_size)
		room.freeze = true
	big_room_list = filter_big_rooms()
	if DEBUG_DRAW:
		draw_big_flag = true
		queue_redraw()
		await get_tree().process_frame
	room_edge_list = get_room_edges()
	if DEBUG_DRAW:
		draw_edges_flag = true
		queue_redraw()
		await get_tree().process_frame
	mst_edge_list = create_mst()
	if DEBUG_DRAW:
		draw_mst_flag = true
		queue_redraw()
		await get_tree().process_frame
	hallways_list = create_hallways()
	if DEBUG_DRAW:
		draw_hallways_flag = true
		queue_redraw()
		await get_tree().process_frame
	final_room_list = create_intersected_room_list()
	save_final_data()
	if DEBUG_DRAW:
		draw_final_flag = true
		queue_redraw()
		await get_tree().process_frame
	cleanup_rooms()
	if DEBUG_DRAW:
		use_final_shapes = true
		queue_redraw()
		await get_tree().process_frame
	place_tiles()

func place_tiles() -> void:
	create_room_tile_list()
	create_hallway_corner_tile_list()
	create_hallway_tile_list()
	place_tile_lists()
	after_place_cleanup()
	finished_placing = true
	room_dreaming_finished.emit(final_positions, final_shapes)

func prepare_tile_list() -> void:
	temp_floor_cord_set.clear()
	temp_wall_cord_set.clear()
	backup_floor_cord_set = floor_cord_set.duplicate()
	backup_wall_cord_set = wall_cord_set.duplicate()

func commit_tile_list() -> void:
	floor_cord_set.merge(temp_floor_cord_set)
	wall_cord_set.merge(temp_wall_cord_set)

func create_room_tile_list() -> void:
	prepare_tile_list()
	place_all_room_tiles()
	commit_tile_list()

func create_hallway_corner_tile_list() -> void:
	prepare_tile_list()
	create_hallway_intersection_list()
	create_all_hallway_intersections()
	commit_tile_list()

func create_hallway_tile_list() -> void:
	prepare_tile_list()
	place_all_hallway_tiles()
	commit_tile_list()

func place_tile_lists() -> void:
	for cell in floor_cord_set.keys():
		tilemap.set_cell(floor_layer,cell,maze_source,Vector2i.ZERO)
	tilemap.set_cells_terrain_connect(wall_layer,wall_cord_set.keys(),0,0)

func after_place_cleanup() -> void:
	temp_floor_cord_set.clear()
	temp_wall_cord_set.clear()
	backup_floor_cord_set.clear()
	backup_wall_cord_set.clear()

func filter_big_rooms() -> Array[RoomShape]:
	return room_list.filter(func(room): return room.get_room_size() >= big_room_start*4*tileset.tile_size.x*tileset.tile_size.y)

func get_room_edges() -> Array[ConnectionEdge]:
	var posarr := PackedVector2Array(big_room_list.map(func(room): return room.global_position))
	var triangulation := Geometry2D.triangulate_delaunay(posarr)
	if(triangulation.is_empty()):
		Logger.error(str("room triangulation failed. report seed ",rand.given_seed," to cheese"))
		return []
	var result: Array[ConnectionEdge] = []
	for i in range(triangulation.size()/3):
		var p1 := triangulation[3*i]
		var p2 := triangulation[3*i+1]
		var p3 := triangulation[3*i+2]
		var room1 := big_room_list[p1]
		var room2 := big_room_list[p2]
		var room3 := big_room_list[p3]
		result.append(ConnectionEdge.new(room1,room2))
		result.append(ConnectionEdge.new(room2,room3))
		result.append(ConnectionEdge.new(room3,room1))
	return result

func create_mst() -> Array[ConnectionEdge]:
	var sorted_edge_list := room_edge_list.duplicate()
	sorted_edge_list.sort_custom(
		func(edge1,edge2):
			return edge1.get_weight() < edge2.get_weight()
	)
	
	var dsu := DisjointSetUnion.new()
	for room in big_room_list:
		dsu.make_set(room)
	
	var result: Array[ConnectionEdge] = []
	for edge in sorted_edge_list:
		var room1 = edge.room1
		var room2 = edge.room2
		if dsu.union(room1,room2):
			result.append(edge)
	for edge in room_edge_list:
		if not edge in result:
			if rand.chance(.1):
				result.append(edge)
	return result

func create_hallways() -> Array[HallwaySegment]:
	var result: Array[HallwaySegment] = []
	for edge in mst_edge_list:
		#50-50 between the two possible directions
		if rand.randi_range(0,1) == 0:
			var hallway1 := HallwaySegment.new(
				Vector2(edge.room1.global_position.x,edge.room1.global_position.y),
				Vector2(edge.room2.global_position.x,edge.room1.global_position.y)
			)
			result.append(hallway1)
			var hallway2 := HallwaySegment.new(
				Vector2(edge.room2.global_position.x,edge.room1.global_position.y),
				Vector2(edge.room2.global_position.x,edge.room2.global_position.y)
			)
			result.append(hallway2)
		else:
			var hallway1 := HallwaySegment.new(
				Vector2(edge.room1.global_position.x,edge.room1.global_position.y),
				Vector2(edge.room1.global_position.x,edge.room2.global_position.y)
			)
			result.append(hallway1)
			var hallway2 := HallwaySegment.new(
				Vector2(edge.room1.global_position.x,edge.room2.global_position.y),
				Vector2(edge.room2.global_position.x,edge.room2.global_position.y)
			)
			result.append(hallway2)
	return result

func check_hallway_intersection(room: RoomShape, hallway: HallwaySegment) -> bool:
	var room_polygon: PackedVector2Array = [
		room.global_position+room.collision.shape.size*Vector2(-1,-1)/2,
		room.global_position+room.collision.shape.size*Vector2(1,-1)/2,
		room.global_position+room.collision.shape.size*Vector2(1,1)/2,
		room.global_position+room.collision.shape.size*Vector2(-1,1)/2
	]
	var hallway_polyline: PackedVector2Array = [
		hallway.pos1, hallway.pos2
	]
	var intersection := Geometry2D.intersect_polyline_with_polygon(hallway_polyline,room_polygon)
	return not intersection.is_empty()

func create_intersected_room_list() -> Array[RoomShape]:
	var result := big_room_list.duplicate()
	for room in room_list:
		#TODO: in for arrays is slow. fix.
		if not room in big_room_list:
			for hallway in hallways_list:
				if check_hallway_intersection(room, hallway):
					result.append(room)
					break
	return result

func save_final_data() -> void:
	for room in final_room_list:
		final_positions.append(room.global_position.snapped(tileset.tile_size))
		final_shapes.append(room.collision.shape)
	final_room_list.clear()

func cleanup_rooms() -> void:
	for room in room_list:
		ObjectPool.return_object(room)
	room_list.clear()
	big_room_list.clear()
	room_edge_list.clear()
	mst_edge_list.clear()

func place_all_room_tiles() -> void:
	for i in range(final_positions.size()):
		place_room_tiles(i)

func place_room_tiles(idx: int) -> void:
	var shape := final_shapes[idx] as RectangleShape2D
	var room_pos := final_positions[idx]
	var pos_offset := room_pos-shape.size/2
	for i in range(0,shape.size.x,tileset.tile_size.x):
		for j in range(0,shape.size.y,tileset.tile_size.y):
			var pos := pos_offset+Vector2(i,j)
			var placepos := tilemap.local_to_map(tilemap.to_local(pos))
			var edge := i == 0 or j == 0 or i == shape.size.x-tileset.tile_size.x or j == shape.size.y-tileset.tile_size.y
			room_tile_set[placepos] = null
			if edge:
				temp_wall_cord_set[placepos] = null
			else:
				temp_floor_cord_set[placepos] = null

func place_all_hallway_tiles() -> void:
	for i in range(hallways_list.size()):
		place_hallway_tiles(i)

func place_hallway_tiles(idx: int) -> void:
	var hallway := hallways_list[idx]
	var from := hallway.pos1
	var fromtile := tilemap.local_to_map(tilemap.to_local(from))
	var to := hallway.pos2
	var totile := tilemap.local_to_map(tilemap.to_local(to))
	var dir := Vector2i(from.direction_to(to))
	var sidedir := Vector2i(dir.y,dir.x).abs()
	var curr := fromtile
	while curr != totile:
		var temp := curr
		for __ in range(hallway_width):
			wall_cord_set.erase(temp)
			temp_wall_cord_set.erase(temp)
			temp_floor_cord_set[temp] = null
			temp += sidedir
		if not temp in room_tile_set and not temp in temp_floor_cord_set:
			floor_cord_set.erase(temp)
			temp_wall_cord_set[temp] = null
			temp_floor_cord_set.erase(temp)
		temp = curr - sidedir
		for __ in range(hallway_width):
			wall_cord_set.erase(temp)
			temp_wall_cord_set.erase(temp)
			temp_floor_cord_set[temp] = null
			temp -= sidedir
		if not temp in room_tile_set and not temp in temp_floor_cord_set:
			floor_cord_set.erase(temp)
			temp_wall_cord_set[temp] = null
			temp_floor_cord_set.erase(temp)
		curr += dir

func create_hallway_intersection_list() -> void:
	for i in range(hallways_list.size()):
		for j in range(i+1,hallways_list.size()):
			var hall1 := hallways_list[i]
			var hall2 := hallways_list[j]
			var intersection = Geometry2D.segment_intersects_segment(hall1.pos1, hall1.pos2, hall2.pos1, hall2.pos2)
			if intersection == null:
				continue
			hallway_intersections_list.append(tilemap.local_to_map(tilemap.to_local(intersection as Vector2)))

func create_all_hallway_intersections() -> void:
	for i in range(hallway_intersections_list.size()):
		create_hallway_intersection(i)

func create_hallway_intersection(idx: int) -> void:
	var pos := hallway_intersections_list[idx]
	for i in range(-hallway_width-1,hallway_width+1):
		for j in range(-hallway_width-1,hallway_width+1):
			var placepos := pos + Vector2i(i,j)
			var edge := i == -hallway_width-1 or j == -hallway_width-1 or i == hallway_width or j == hallway_width
			if not edge:
				wall_cord_set.erase(placepos)
				temp_wall_cord_set.erase(placepos)
				temp_floor_cord_set[placepos] = null
			if edge and not placepos in room_tile_set:
				temp_wall_cord_set[placepos] = null
			room_tile_set[placepos] = null

func _physics_process(_delta: float) -> void:
	if not finished:
		queue_redraw()
#this is some very messy debug code
var draw_big_flag: bool = false
var draw_edges_flag: bool = false
var draw_mst_flag: bool = false
var draw_hallways_flag: bool = false
var draw_final_flag: bool = false
var use_final_shapes: bool = false
func _draw() -> void:
	if not DEBUG_DRAW: return
	if finished_placing: return
	for room in room_list:
		if not use_final_shapes:
			if not is_instance_valid(room) or not room.is_inside_tree(): continue
			draw_set_transform(to_local(room.global_position))
			var color := Color(1,1,1,0.3 if not draw_big_flag else 0.1)
			draw_rect(room.collision.shape.get_rect(), color)
			color = Color(1,1,1,0.5 if not draw_big_flag else 0.2)
			draw_rect(room.collision.shape.get_rect(), color, false)
			draw_set_transform(Vector2.ZERO)
	if draw_big_flag:
		if not use_final_shapes:
			for room in big_room_list:
				if not is_instance_valid(room) or not room.is_inside_tree(): continue
				draw_set_transform(to_local(room.global_position))
				var color := Color(1,0,0,0.1)
				room.collision.shape.draw(get_canvas_item(), color)
				draw_set_transform(Vector2.ZERO)
		else:
			for i in range(final_positions.size()):
				var pos := final_positions[i]
				var shape := final_shapes[i]
				draw_set_transform(to_local(pos))
				var color := Color(1,0,0,0.5)
				draw_rect(shape.get_rect(), color, false)
				draw_set_transform(Vector2.ZERO)
	if draw_edges_flag and not use_final_shapes:
		for edge in room_edge_list:
			var room1 := edge.room1
			var room2 := edge.room2
			var pos1 = to_local(room1.global_position)
			var pos2 = to_local(room2.global_position)
			var color := Color(0,1,0,0.5 if not draw_mst_flag else 0.1)
			draw_line(pos1, pos2, color)
	if draw_mst_flag and not use_final_shapes:
		for edge in mst_edge_list:
			var room1 := edge.room1
			var room2 := edge.room2
			var pos1 = to_local(room1.global_position)
			var pos2 = to_local(room2.global_position)
			var color := Color(0,0,1,0.8 if not draw_hallways_flag else 0.3)
			draw_line(pos1, pos2, color)
	if draw_hallways_flag:
		for hallway in hallways_list:
			var pos1 := to_local(hallway.pos1)
			var pos2 := to_local(hallway.pos2)
			var color := Color(1,1,0,0.8)
			draw_line(pos1,pos2,color)
	if draw_final_flag:
		if not use_final_shapes:
			for room in final_room_list:
				if room in big_room_list: continue
				draw_set_transform(to_local(room.global_position))
				var color := Color(0,1,1,0.1)
				draw_rect(room.collision.shape.get_rect(), color, false)
				draw_set_transform(Vector2.ZERO)
		else:
			for i in range(final_positions.size()):
				var pos := final_positions[i]
				var shape := final_shapes[i]
				if shape.size.x*shape.size.y >= big_room_start*4*tileset.tile_size.x*tileset.tile_size.y:
					continue
				draw_set_transform(to_local(pos))
				var color := Color(0,1,1,0.5)
				draw_rect(shape.get_rect(), color, false)
				draw_set_transform(Vector2.ZERO)
