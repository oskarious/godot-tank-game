extends Node2D

onready var tile_prefab = preload("res://map/tile/tile.tscn");

export(Vector2) var map_size;
export(float) var tile_size;

var tiles = [];

func _ready():
	var map_image = generate_voronoi_diagram(map_size, 15)
	map_image.lock()
	
	for x in range(map_size.x):
		tiles.append([])
		tiles[x].resize(map_size.y)
		
#		Pos as own var as we are accessing it multiple times
		var pos = Vector2(x * tile_size, 0)
		
		for y in range(map_size.y):
			var tile = tile_prefab.instance()
			pos.y = y * tile_size
			
			tile.position = pos
			tile.name = "Tile{x}-{y}".format({"x": pos.x, "y": pos.y})
			tiles[x][y] = tile;
			tile.type = tile.get_tile_type_from_color(map_image.get_pixel(x,y))
			
			add_child(tile)
				
	map_image.unlock()

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
		var colorPossibilities = [ Color.blue, Color.red, Color.green, Color.purple]
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
