extends Area2D

export(int) var round_movement = 10

var pathfinding: Pathfinding
var path: Array

# Called when the node enters the scene tree for the first time.
func _ready():
	$Line2D.default_color = $Sprite.modulate
	
func path_to_point(x,y):
	var points = pathfinding.astar.get_points()
	path = pathfinding.get_tiles_path(position, Vector2(x,y))
	print(path)
	for i in path:
		$Line2D.add_point(to_local(i))

#func _get_max_on_path():
#	for i in path:
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
