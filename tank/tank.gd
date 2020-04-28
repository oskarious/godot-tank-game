extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var pathfinding: Pathfinding
var path: Array

# Called when the node enters the scene tree for the first time.
func _ready():
	$Line2D.default_color = $Sprite.modulate
	
func path_to_point(x,y):
	var points = pathfinding.astar.get_points()
	path = pathfinding.get_tiles_path(position, Vector2(x,y))
	for i in path:
		$Line2D.add_point(to_local(i))


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
