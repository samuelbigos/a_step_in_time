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
		var player = get_tree().get_nodes_in_group("player")[0]
		var goal = get_tree().get_nodes_in_group("goal")[0]
		
		var playerMove = player.getGridPos() + player.getDesiredMove()
		if goal._gridPos == playerMove:
			_completeLevel()
		else:
			_grid.step()

func _completeLevel():
	PlayerData.completeCurrentLevel()
	get_tree().reload_current_scene()
