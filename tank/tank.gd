extends Area2D

class_name Tank

export(int) var movement_budget = 10
var team = 0
var health = 100

var pathfinding: Pathfinding
var path: Array
var map: Map

# Called when the node enters the scene tree for the first time.
func _ready():
	map = get_node("../Map")
	on_move_ended()
	# pass
	
func set_tank_team(team: int):
	self.team = team
	var color = Color.blue
	if(team == 1):
		color = Color.red
		
	$Sprite.modulate = color
	var line_color = Color().from_hsv(color.h, color.s, color.v, 0.33)
	$NavLine.default_color = line_color
		

func on_move_started():
	var tile = map.tile_at_world_space(position)
	tile.tank = null

func on_move_ended():
	var tile = map.tile_at_world_space(position)
	tile.tank = self
	print(tile.name)
	
func path_to_point(pos: Vector2):
	var cost = 0
	var tiles = []
	for i in pathfinding.get_tiles_path(position, pos):
		var tile = map.tile_at_world_space(i)
		cost += tile.movement_cost

		if(cost >= movement_budget):
			break
		
		tiles.push_back(tile)
		$NavLine.add_point(to_local(i))
	print(cost)

#func _get_max_on_path():
#	for i in path:
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
