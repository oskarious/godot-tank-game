extends Area2D

class_name Tank

export(int) var movement_budget = 10
var team = 0
var health = 100

var pathfinding: Pathfinding
var path: Array
var map: Map
var nav_line: Line2D
var move_end: Sprite

var move_to_tile: Tile
var move_cost = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	map = get_node("../Map")
	nav_line = $NavLine
	move_end = $moveEnd
	map.tile_at_world_space(position).tank = self

func set_tank_team(_team: int):
	self.team = _team
	var color = Color.blue
	if(_team == 1):
		color = Color.red
		
	$Sprite.modulate = color
	var line_color = Color().from_hsv(color.h, color.s, color.v, 0.33)
	nav_line.default_color = line_color

	
func path_to_point(pos: Vector2):
	nav_line.clear_points()
	move_end.show()
	var cost = 0
	var tiles = []
	for i in pathfinding.get_tiles_path(position, pos):
		var tile = map.tile_at_world_space(i)

		if(cost + tile.movement_cost > movement_budget):
			move_cost = cost
			break
		
		cost += tile.movement_cost
		move_to_tile = tile
		
		tiles.push_back(tile)
		nav_line.add_point(to_local(i))
		move_end.position = to_local(i)
	print(cost)

func move():
	var from_tile = map.tile_at_world_space(position)
	from_tile.tank = null
	move_to_tile.tank = self
	position = map.tile_to_world(move_to_tile.tile_position.x, move_to_tile.tile_position.y)
	movement_budget -= move_cost
	move_cost = 0
	move_to_tile = null
	deselect()

func deselect():
	nav_line.clear_points()
	move_end.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
