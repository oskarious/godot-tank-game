extends Node2D

enum TileType {
	GRASS,
	WATER,
	WOODS,
	BUILDING,
	VOID
}

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var type = TileType.GRASS
var movement_cost = 1; 

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func get_tile_type_from_color(color: Color):
	match color:
		Color.green:
			return TileType.GRASS
		Color.red:
			return TileType.BUILDING
		Color.blue:
			return TileType.WATER
		Color.purple:
			return TileType.BUILDING
	return TileType.VOID
