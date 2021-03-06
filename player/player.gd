extends Node2D
class_name Player

enum SelectionMode {
	INFO,
	MOVE,
	ATTACK
}

signal tile_selected(player, tile)
signal state_changed(player, state)

onready var tank_class = preload("res://tank/tank.gd")

export(float) var scroll_speed = 400

var selection_mode = SelectionMode.INFO

var selected_tank: Tank
var selected_tile: Tile
var team = 0
var map: Map
var selection_area: Line2D
var selection_preview: Line2D
var camera: Camera2D

# Called when the node enters the scene tree for the first time.
func _ready():
	selection_area = $SelectionArea
	selection_preview = $PreviewSelection
	camera = $PlayerCam
	map = $"../Map"
	camera.position = map.tile_to_world(map.map_size.x/2, map.map_size.y/2)


func _input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_mask == BUTTON_LEFT:
				if selection_mode == SelectionMode.INFO:
					select_tile()
				elif selection_mode == SelectionMode.MOVE:
					move_tank()
			elif event.button_mask == BUTTON_RIGHT:
				_on_right_click()
	
	if event is InputEventMouseMotion:
		set_preview()

func set_preview():
	var mouse_pos = tile_from_mouse()
	if map.in_map_bounds(map.world_to_tile(mouse_pos.x, mouse_pos.y)):
		selection_preview.position = to_local(mouse_pos)
		if selected_tank && selection_mode == SelectionMode.MOVE:
			selected_tank.path_to_point(mouse_pos)

func move_tank():
	if !selected_tank:
		return
	selected_tank.move()
	_change_selection_mode(SelectionMode.INFO)

func select_tile():
	var mouse_pos = tile_from_mouse()
	if map.in_map_bounds(map.world_to_tile(mouse_pos.x, mouse_pos.y)):
		selected_tile = map.tile_at_world_space(mouse_pos)
		selected_tank = selected_tile.tank
		selection_area.position = to_local(mouse_pos)
		emit_signal("tile_selected", self, selected_tile)

func tile_from_mouse():
	var pos = get_global_mouse_position()
	var mouse_pos = Vector2()
	mouse_pos.x = floor(pos.x/map.tile_map.cell_size.x)*map.tile_map.cell_size.x
	mouse_pos.y = floor(pos.y/map.tile_map.cell_size.y)*map.tile_map.cell_size.y
	return mouse_pos



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var dir = Vector2()
	if(Input.is_action_pressed("ui_down")):
		dir.y += 1 * scroll_speed	
	if(Input.is_action_pressed("ui_up")):
		dir.y -= 1 * scroll_speed
	if(Input.is_action_pressed("ui_right")):
		dir.x += 1 * scroll_speed
	if(Input.is_action_pressed("ui_left")):
		dir.x -= 1 * scroll_speed
		
	camera.position += dir * delta

func _change_selection_mode(mode):
	selection_mode = mode
	emit_signal("state_changed", self, selection_mode)

func _on_right_click():
	_change_selection_mode(SelectionMode.INFO)
	
func _on_PlayerHUD_attack_clicked():
	_change_selection_mode(SelectionMode.ATTACK)
		
func _on_PlayerHUD_move_clicked():
	_change_selection_mode(SelectionMode.MOVE)
