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
	
	var b1 = tank_prefab.instance()
	b1.position = map.tile_to_world(map.blue_start.x, map.blue_start.y)
	b1.pathfinding = map.pathfinding
	b1.set_tank_team(0)
	add_child(b1)
	
	var r1 = tank_prefab.instance()
	r1.position = map.tile_to_world(map.red_start.x, map.red_start.y)
	r1.pathfinding = map.pathfinding
	r1.set_tank_team(1)
	add_child(r1)
	
	b1.path_to_point(map.tile_to_world(map.center_town.x, map.center_town.y))
	r1.path_to_point(map.tile_to_world(map.center_town.x, map.center_town.y))
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
