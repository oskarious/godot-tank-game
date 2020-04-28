extends Node2D
class_name Map

onready var tile_prefab = preload("res://map/tile/tile.tscn");

onready var tile_map: TileMap = $TileMap

export(Vector2) var map_size;
export(float) var tile_size;
export(float) var towns;
export(float) var town_min_distance;

var tiles = [];
var tile_set: TileSet;
var random = RandomNumberGenerator.new()
var pathfinding: Pathfinding

func _ready():
	var map_image = generate_voronoi_diagram(map_size, 64)
	map_image.lock()
	tile_set = tile_map.get_tileset()
	pathfinding = $Pathfinding
	
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
	
func _set_tile(position: Vector2, type: int):
	var tile = tiles[position.x][position.y]
	tile.type = type
	tile.movement_cost = tile.get_movement_cost_from_type(tile.type)
	tile_map.set_cell(position.x, position.y, tile_set.find_tile_by_name(tile.TileType.keys()[tile.type]))
	
func generate_towns():
	for _i in range(towns):
		var town_position = Vector2(random.randi_range(0, map_size.x+1), random.randi_range(0, map_size.y+1))
		
		while(tiles[town_position.x][town_position.y].type == Tile.TileType.BUILDING):
			town_position = Vector2(random.randi_range(0, map_size.x+1), random.randi_range(0, map_size.y+1))
			print("Oops, we were taken")
			
		var size = random.randi_range(3,7)
		for x in range(size):
			for y in range(size):
				var pos = Vector2(town_position.x + x, town_position.y + y)
				var tile = tiles[pos.x][pos.y]
				_set_tile(Vector2(pos.x,pos.y), tile.TileType.BUILDING)
	pass

func tile_coord_to_pixel_space(x,y, half=false):
	var mulX = tile_map.cell_size.x
	var mulY = tile_map.cell_size.y
	if(half):
		mulX /= 2
		mulY /=2
		
	return Vector2(x * mulX, y * mulY)

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
