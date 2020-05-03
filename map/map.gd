#Generates the world map
extends Node2D
class_name Map

onready var tile_prefab = preload("res://map/tile/tile.tscn");

onready var tile_map: TileMap = $TileMap

export(Vector2) var map_size;

var tiles = [];
var tile_set: TileSet;
var random = RandomNumberGenerator.new()
var pathfinding: Pathfinding

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
	
	generate_roads(generate_towns())
	pathfinding.connect_points(self)


func _set_tile(position: Vector2, type: int, flip_x = false, flip_y = false, transpose = false):
	var tile = tiles[position.x][position.y]
	tile.type = type
	tile.movement_cost = tile.get_movement_cost_from_type(tile.type)
	tile_map.set_cell(position.x, position.y, tile_set.find_tile_by_name(tile.TileType.keys()[tile.type]), flip_x, flip_y, transpose)
	return tile


func generate_towns():
	var town_positions: PoolVector2Array = []
	var small_size = 3
	var large_size = 5
	
	var yHalf = map_size.y / 2
	var y1 = Vector2(random.randi_range(small_size, map_size.x - small_size), yHalf * 1.5)
	var y2 = Vector2(random.randi_range(large_size, map_size.x - large_size), yHalf)
	var y3 = Vector2(random.randi_range(small_size, map_size.x - small_size), yHalf / 2)

	town_positions.push_back(y1)
	town_positions.push_back(y2)
	town_positions.push_back(y3)

	for t in town_positions:
		var size = small_size
		var diff = small_size - ceil(small_size/2)
		if(t.y == yHalf):
			size = large_size
			diff = large_size - ceil(large_size/2)
		
		for x in range(size):
			for y in range(size):
				var pos = Vector2(t.x + x, t.y + y)
				pos.x -= size - diff
				pos.y -= size - diff
				
				var tile = tiles[pos.x][pos.y]
				_set_tile(tile.tile_position, tile.TileType.BUILDING)

	return town_positions
		


func generate_roads(town_positions: PoolVector2Array):
	town_positions.insert(0, blue_start)
	_set_tile(blue_start, Tile.TileType.ROAD)

	town_positions.push_back(red_start)
	_set_tile(red_start, Tile.TileType.ROAD)

	for t in town_positions:
		print(t)
		print(blue_start.y - t.y)

	for i in range(town_positions.size()-1):
		_set_road_tile(town_positions[i], town_positions[i+1])
	

func _set_road_tile(prev_node: Vector2, t: Vector2):
	var corner_end = Vector2(prev_node.x, t.y)
	var corner_flip_x = true
	var corner_start = Vector2(t.x, prev_node.y)
	for i in range(prev_node.y - t.y):
		_set_tile(tiles[prev_node.x][t.y + i].tile_position, Tile.TileType.ROAD)

	var x_dir = prev_node.x - t.x
	for i in abs(x_dir):
		if(x_dir < 0):
			i = -i
			corner_flip_x = false
		_set_tile(tiles[prev_node.x - i][t.y].tile_position, Tile.TileType.ROAD, false, false, true)

	# _set_tile(corner_start, Tile.TileType.ROAD_CORNER, corner_flip_x, false, true)
	_set_tile(corner_end, Tile.TileType.ROAD_CORNER, corner_flip_x, false, true)


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
