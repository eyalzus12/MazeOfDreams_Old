extends Node2D
class_name MazeDreamer

const CHARACTER := preload("res://Objects/Entity/Character/Character.tscn")

@onready var room_dreamer: Node2D = $RoomDreamer
@onready var room_decorator: Node2D = $RoomDecorator

var positions: Array[Vector2]
var shapes: Array[Shape2D]
@onready var tilemap: TileMapExtensions = $TileMap

var rand: Random = Random.new()

func seed_with(x) -> void:
	rand.seed_with(x)

func _ready() -> void:
	rand.seed_random()
	dream_rooms()

func dream_rooms() -> void:
	room_dreamer.rand = rand
	room_dreamer.tilemap = tilemap
	room_dreamer.room_dreaming_finished.connect(on_room_dreaming_finished)
	room_dreamer.init_spread()

func decorate_rooms() -> void:
	room_decorator.positions = positions
	room_decorator.shapes = shapes
	
	room_decorator.rand = rand
	room_decorator.tilemap = tilemap
	room_decorator.room_decoration_finished.connect(on_room_decoration_finished)
	room_decorator.init_decorating()

func on_room_dreaming_finished(positions_: Array[Vector2], shapes_: Array[Shape2D]) -> void:
	positions = positions_
	shapes = shapes_
	decorate_rooms()

func on_room_decoration_finished() -> void:
	var character := ObjectPool.load_object(CHARACTER)
	character.global_position = positions[0]
	add_child(character)
