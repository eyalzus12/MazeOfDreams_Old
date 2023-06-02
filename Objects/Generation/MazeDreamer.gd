extends Node2D
class_name MazeDreamer

const ROOM_SHAPE := preload("res://Objects/Generation/RoomShape.tscn")

@export var starting_room_shape: PackedScene = preload("res://Objects/Generation/RoomShape.tscn")
@export var generated_room_amount: int = 150
@export var min_room_size: int = 10
@export var max_room_size: int = 60
@export var big_room_start: int = 2000
@export var placement_radius: float = 200

@export var max_spread_wait: float = 5
@export var spread_finish_check_interval: float = 0.1

var rand = Random.new()
var room_list: Array[RoomShape] = []
var big_room_list: Array[RoomShape] = []
var room_edge_list: Array[ConnectionEdge] = []
var mst_edge_list: Array[ConnectionEdge] = []
var hallways_list: Array[HallwaySegment] = []
var final_room_list: Array[RoomShape] = []
var check_timer: Timer
var timeout_timer: Timer

func seed_with(x) -> void:
	rand.seed_with(x)

func create_random_room() -> RoomShape:
	var room_shape: RoomShape = ObjectPool.load_object(ROOM_SHAPE)
	var collision_shape := RectangleShape2D.new()
	collision_shape.size = Vector2(
		rand.randi_range(min_room_size, max_room_size),
		rand.randi_range(min_room_size, max_room_size)
	)
	var room_shape_collision = room_shape.get_node("RoomShapeCollision")
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
	draw_edges_flag = false
	draw_big_flag = false
	draw_mst_flag = false
	draw_hallways_flag = false
	draw_final_flag = false
	create_and_place_rooms()
	timeout_timer = Globals.add_temp_timer(self, max_spread_wait)
	timeout_timer.timeout.connect(spread_timeout)
	check_timer = Globals.add_loop_timer(self, spread_finish_check_interval)
	check_timer.timeout.connect(check_spread_finish)
	Engine.physics_ticks_per_second = 300
	Engine.max_physics_steps_per_frame = 40

func spread_timeout() -> void:
	push_error("spreading took too long")
	finish_spread()

func check_spread_finish() -> void:
	var finished := true
	for room in room_list:
		room.global_position = room.global_position.snapped(Vector2.ONE)
	for room in room_list:
		if not room.sleeping:
			finished = false
			break
	if finished:
		finish_spread()

func finish_spread() -> void:
	Engine.physics_ticks_per_second = 60
	Engine.max_physics_steps_per_frame = 8
	timeout_timer.queue_free()
	check_timer.queue_free()
	for room in room_list:
		room.global_position = room.global_position.snapped(Vector2.ONE)
	big_room_list = filter_big_rooms()
	draw_big_flag = true
	room_edge_list = get_room_edges()
	draw_edges_flag = true
	mst_edge_list = create_mst()
	draw_mst_flag = true
	hallways_list = create_hallways()
	draw_hallways_flag = true
	final_room_list = create_intersected_room_list()
	draw_final_flag = true

func filter_big_rooms() -> Array[RoomShape]:
	return room_list.filter(func(room): return room.get_room_size() >= big_room_start)

func get_room_edges() -> Array[ConnectionEdge]:
	var posarr := PackedVector2Array(big_room_list.map(func(room): return room.global_position))
	var triangulation := Geometry2D.triangulate_delaunay(posarr)
	if(triangulation.is_empty()):
		push_error("room triangulation failed")
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
	return result

func _ready() -> void:
	rand.seed_random()
	init_spread()

func _physics_process(_delta: float) -> void:
	queue_redraw()

var draw_big_flag: bool = false
var draw_edges_flag: bool = false
var draw_mst_flag: bool = false
var draw_hallways_flag: bool = false
var draw_final_flag: bool = false
func _draw() -> void:
	for room in room_list:
		if not room.is_inside_tree(): continue
		draw_set_transform(to_local(room.global_position))
		var color := Color(1,1,1,0.3 if not draw_big_flag else 0.1)
		room.collision.shape.draw(get_canvas_item(), color)
		draw_set_transform(Vector2.ZERO)
	if draw_big_flag:
		for room in big_room_list:
			if not room.is_inside_tree(): continue
			draw_set_transform(to_local(room.global_position))
			var color := Color(1,0,0,0.1)
			room.collision.shape.draw(get_canvas_item(), color)
			draw_set_transform(Vector2.ZERO)
	if draw_edges_flag:
		for edge in room_edge_list:
			var room1 := edge.room1
			var room2 := edge.room2
			var pos1 = to_local(room1.global_position)
			var pos2 = to_local(room2.global_position)
			var color := Color(0,1,0,0.5 if not draw_mst_flag else 0.1)
			draw_line(pos1, pos2, color)
	if draw_mst_flag:
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
			draw_line(pos1,pos2,color,2)
	if draw_final_flag:
		for room in final_room_list:
			if room in big_room_list: continue
			draw_set_transform(to_local(room.global_position))
			var color := Color(0,1,1,0.1)
			room.collision.shape.draw(get_canvas_item(), color)
			draw_set_transform(Vector2.ZERO)
