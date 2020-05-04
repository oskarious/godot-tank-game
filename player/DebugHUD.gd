extends Control

var selection_mode: Label

func _ready():
	selection_mode = $VBoxContainer/SelectionState


func _on_Player_state_changed(player, state):
	selection_mode.text = "Selection mode: " + Player.SelectionMode.keys()[state]
