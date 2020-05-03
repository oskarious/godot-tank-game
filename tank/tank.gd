extends Area2D

export(int) var round_movement = 10

var pathfinding: Pathfinding
var path: Array

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func set_tank_team(team: int):
	var color = Color.blue
	if(team == 1):
		color = Color.red
		
	$Sprite.modulate = color
	var line_color = Color().from_hsv(color.h, color.s, color.v, 0.33)
	$Line2D.default_color = line_color
	
	
func path_to_point(pos: Vector2):
	for i in pathfinding.get_tiles_path(position, pos):
		$Line2D.add_point(to_local(i))

#func _get_max_on_path():
#	for i in path:
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
