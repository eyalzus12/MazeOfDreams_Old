extends Node2D
class_name MazeDreamer

const CHARACTER := preload("res://Objects/Entity/Character/Character.tscn")

@onready var room_dreamer: RoomDreamer = $RoomDreamer
@onready var room_decorator: RoomDecorator = $RoomDecorator

var positions: Array[Vector2]
var shapes: Array[Shape2D]
@onready var tilemap: TileMapExtensions = $TileMap

var rand: Random = Random.new()

func seed_with(x) -> void:
	rand.seed_with(x)

func _ready() -> void:
	Logger.logs("maze dreaming started")
	rand.seed_random()
	dream_rooms()

func dream_rooms() -> void:
	Logger.logs("room dreaming started")
	room_dreamer.rand = rand
	room_dreamer.tilemap = tilemap
	room_dreamer.room_dreaming_finished.connect(on_room_dreaming_finished)
	room_dreamer.init_spread()

func decorate_rooms() -> void:
	Logger.logs("room decorating started")
	room_decorator.positions = positions
	room_decorator.shapes = shapes
	
	room_decorator.rand = rand
	room_decorator.tilemap = tilemap
	room_decorator.room_decoration_finished.connect(on_room_decoration_finished)
	room_decorator.init_decorating()

func on_room_dreaming_finished(positions_: Array[Vector2], shapes_: Array[Shape2D]) -> void:
	Logger.logs("room dreaming finished")
	positions = positions_
	shapes = shapes_
	decorate_rooms()

func on_room_decoration_finished() -> void:
	Logger.logs("room decorating finished")
	Logger.logs("maze dreaming finished")
	var character := ObjectPool.load_object(CHARACTER)
	character.global_position = positions[0]
	add_child(character)
