extends Node2D

onready var tank_prefab = preload("res://tank/tank.tscn")

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var red_start: Vector2
var blue_start: Vector2
var map: Map

# Called when the node enters the scene tree for the first time.
func _ready():
	map = $Map
	var w = map.map_size.x
	var h = map.map_size.y
	red_start = map.tile_coord_to_pixel_space(w/2 - 1, 0)
	blue_start = map.tile_coord_to_pixel_space(w/2 - 1, h - 1)
	
	var b1 = tank_prefab.instance()
	b1.position = blue_start
	b1.pathfinding = map.pathfinding
	b1.get_node("Sprite").modulate = Color.blue
	add_child(b1)
	
	var r1 = tank_prefab.instance()
	r1.position = red_start
	r1.pathfinding = map.pathfinding
	r1.get_node("Sprite").self_modulate = Color.red
	add_child(r1)
	
	b1.path_to_point(0,0)
	r1.path_to_point(0,0)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
