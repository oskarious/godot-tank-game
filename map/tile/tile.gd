extends Node

enum TileType {
	GRASS
	WATER
	WOODS
	BUILDING
	VOID
}

var type = TileType.GRASS
var movement_cost = 1;
var tile_position: Vector2

func _ready():
	pass # Replace with function body.

func get_movement_cost_from_type(type: int):
	match(type):
		TileType.BUILDING,TileType.WATER:
			return -1
		TileType.GRASS:
			return 1
		TileType.WOODS:
			return 3
	return 1

func get_tile_type_from_color(color: Color):
	match color:
		Color.green:
			return TileType.GRASS
		Color.red:
			return TileType.BUILDING
		Color.blue:
			return TileType.WATER
		Color.yellow:
			return TileType.WOODS
			
	return TileType.VOID
