extends Camera2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export(float) var scroll_speed = 400

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


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
		
	position += dir * delta
