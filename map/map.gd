extends Node2D
class_name Map

onready var tile_prefab = preload("res://map/tile/tile.tscn");

onready var tile_map: TileMap = $TileMap

export(Vector2) var map_size;
export(float) var towns_amount;
export(float) var town_min_distance;

var tiles = [];
var tile_set: TileSet;
var random = RandomNumberGenerator.new()
var pathfinding: Pathfinding
var town_positions: PoolVector2Array

var blue_start: Vector2
var red_start: Vector2

func _ready():
	random.randomize()
	
	var map_image = generate_voronoi_diagram(map_size, 64)
	map_image.lock()
	tile_set = tile_map.get_tileset()
	pathfinding = $Pathfinding
	
	var w = map_size.x
	var h = map_size.y
	red_start = Vector2(w/2 - 1, 0)
	blue_start = Vector2(w/2 - 1, h - 1)
	
	var idx = 0
	for x in range(map_size.x):
		tiles.append([])
		tiles[x].resize(map_size.y)
		
		for y in range(map_size.y):
			
			var tile = tile_prefab.instance()
			
			tile.tile_position = Vector2(x,y)
			tile.name = "Tile{x}-{y}".format({"x": x, "y": y})
			tile.type = tile.get_tile_type_from_color(map_image.get_pixel(x,y))
			tiles[x][y] = tile;
			_set_tile(Vector2(x,y), tile.type)
			pathfinding.add_tile(tile, self, idx)
			idx += 1
			
	map_image.unlock()
	
	generate_towns()
	pathfinding.connect_points(self)
	generate_roads()


func _set_tile(position: Vector2, type: int):
	var tile = tiles[position.x][position.y]
	tile.type = type
	tile.movement_cost = tile.get_movement_cost_from_type(tile.type)
	tile_map.set_cell(position.x, position.y, tile_set.find_tile_by_name(tile.TileType.keys()[tile.type]))


func generate_towns():
	for _i in towns_amount:
		var town_position = Vector2(random.randi_range(0, map_size.x), random.randi_range(0, map_size.y))
		var size = 3 * random.randi_range(1,1)
		
		# TODO: Don't brute force position check for town generation
		while(tiles[town_position.x-1][town_position.y-1].type == Tile.TileType.BUILDING 
		|| !in_map_bounds(town_position) 
		|| !in_map_bounds(Vector2(town_position.x - size, town_position.y - size))):
			town_position = Vector2(random.randi_range(0, map_size.x), random.randi_range(0, map_size.y))
			print("Oops, town already exists on position")
		
		town_positions.push_back(town_position)
		
		for x in range(size):
			for y in range(size):
				var pos = Vector2(town_position.x + x, town_position.y + y)
				pos.x -= size
				pos.y -= size
				
				var tile = tiles[pos.x][pos.y]
				_set_tile(tile.tile_position, tile.TileType.BUILDING)
		


func generate_roads():
	var sorted: PoolVector2Array = []
	for t in town_positions:
		# Borken
		if(t != null && blue_start.distance_to(t) < blue_start.distance_to(t)):
			sorted.insert(0,t)
		else:
			sorted.push_back(t)
		_set_tile(t, Tile.TileType.ROAD)
	
	sorted.insert(0, blue_start)
	_set_tile(blue_start, Tile.TileType.ROAD)
	
	sorted.push_back(red_start)
	_set_tile(red_start, Tile.TileType.ROAD)

	for i in range(sorted.size()-1):
		_set_road_tile(sorted[i], sorted[i+1])
	_set_road_tile(sorted[sorted.size()-1], sorted[sorted.size()-2])
	

func _set_road_tile(prev_node: Vector2, t: Vector2):
	for i in range(prev_node.y - t.y):
		_set_tile(tiles[prev_node.x][t.y + i].tile_position, Tile.TileType.ROAD)
	
	var x_dir = prev_node.x - t.x
	for i in abs(x_dir):
		if(x_dir < 0):
			i = -i
		_set_tile(tiles[prev_node.x - i][t.y].tile_position, Tile.TileType.ROAD)

func tile_to_world_space(x,y, half=false):
	var mulX = tile_map.cell_size.x
	var mulY = tile_map.cell_size.y
	if(half):
		mulX /= 2
		mulY /=2
		
	return Vector2(x * mulX, y * mulY)


func in_map_bounds(pos: Vector2):
	return pos.x < map_size.x && pos.y < map_size.y && pos.x > 0 && pos.y > 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass



#https://www.reddit.com/r/godot/comments/bazs8m/quick_voronoi_diagram/
func generate_voronoi_diagram(imgSize : Vector2, num_cells: int):

	var img = Image.new()
	img.create(imgSize.x, imgSize.y, false, Image.FORMAT_RGBH)

	var points = []
	var colors = []

	for _i in range(num_cells):
		points.push_back(Vector2(int(randf()*img.get_size().x), int(randf()*img.get_size().y)))

		randomize()
		# R=Building,G=Grass,B=Water,Yellow=Woods
		var colorPossibilities = [ Color.green, Color.yellow]
#		var colorPossibilities = [ Color.blue, Color.red, Color.green, Color.purple, Color.yellow, Color.orange]
		colors.push_back(colorPossibilities[randi()%colorPossibilities.size()])
		

	for y in range(img.get_size().y):
		for x in range(img.get_size().x):
			var dmin = img.get_size().length()
			var j = -1
			for i in range(num_cells):
				var d = (points[i] - Vector2(x, y)).length()
				if d < dmin:
					dmin = d
					j = i
			img.lock()
			img.set_pixel(x, y, colors[j])
			img.unlock()
			
	return img;
