extends Node2D

onready var _grid = get_node("Grid")


func _ready():
	pass

func _process(delta):
	var step = false
	if (Input.is_action_just_released("up") or 
		Input.is_action_just_released("down") or 
		Input.is_action_just_released("left") or 
		Input.is_action_just_released("right")):
		step = true
		
	if step:
		_grid.step()
