extends Control

export var GameScene:= ""
export var LevelSelectScene:= ""

var timer = 0.05


func _process(delta):
	timer -= delta
	if timer < 0.0:
		if PlayerData.get("next_scene") == "game":
			get_tree().change_scene(GameScene)
		if PlayerData.get("next_scene") == "level_select":
			get_tree().change_scene(LevelSelectScene)
