extends Control
class_name Player_hud

signal move_clicked
signal attack_clicked

var tile_position: Label
var tile_type: Label
var tile_movement_cost: Label

var tank_container: Container
var tank_team: Label
var tank_health: Label
var tank_movement_budget: Label

var move: Button
var attack: Button

# Called when the node enters the scene tree for the first time.
func _ready():
	tile_position = $"Infobar/TilePanel/Tile Info VBox/Position/Tile position data"
	tile_type = $"Infobar/TilePanel/Tile Info VBox/Type/Tile type data"
	tile_movement_cost = $"Infobar/TilePanel/Tile Info VBox/Movement/Movement cost data"
	
	tank_container = $"Infobar/Tank Panel"
	tank_team = $"Infobar/Tank Panel/Tank info VBox/Team/Team data"
	tank_health = $"Infobar/Tank Panel/Tank info VBox/Health/Health data"
	tank_movement_budget = $"Infobar/Tank Panel/Tank info VBox/Movement/Movement budget data"
	
	move = $"ActionsContainer/Action buttons/Move"
	attack = $"ActionsContainer/Action buttons/Attack"
	

func set_tile_data(tile: Tile):
	tile_position.text = String(tile.tile_position)
	tile_type.text = Tile.TileType.keys()[tile.type]
	tile_movement_cost.text = String(tile.movement_cost)

func set_tile_tank_data(tank: Tank, player: Player):
	if tank:
		tank_container.show()

		move.disabled = tank.team != player.team
		attack.disabled = tank.team != player.team
		if tank.team == player.team:
			tank_team.text = String(tank.team)
			tank_health.text = String(tank.health)
			tank_movement_budget.text = String(tank.movement_budget)
	else:
		tank_container.hide()
		move.disabled = true
		attack.disabled = true

func _on_Player_tile_selected(player: Player, tile: Tile):
	set_tile_data(tile)
	set_tile_tank_data(tile.tank, player)


func _on_Move_pressed():
	emit_signal("move_clicked")


func _on_Attack_pressed():
	emit_signal("attack_clicked")
