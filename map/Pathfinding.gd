extends Node

class_name Pathfinding

var astar = AStar2D.new()

func add_tile(tile: Tile, map, idx: int):
	astar.add_point(idx,
		map.tile_to_world_space(tile.tile_position.x, tile.tile_position.y), 
		tile.movement_cost)

func connect_points(map):
	for i in range(astar.get_points().size()):
		if(astar.has_point(i+1)):
			astar.connect_points(i, i+1) # right
		if(astar.has_point(i+map.map_size.y)):
			astar.connect_points(i, i+map.map_size.y) #bot

func _get_point_at_position(pos: Vector2):
	return astar.get_points()[pos.x+pos.y]

func get_tiles_path(from: Vector2, to: Vector2):
	return astar.get_point_path(astar.get_closest_point(from), astar.get_closest_point(to))
