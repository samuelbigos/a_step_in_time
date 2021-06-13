extends Control

export var LevelButton: PackedScene
export var KeyButton: PackedScene
export var TransitionScene: PackedScene


func _ready():
	for i in range(0, Globals.Levels.size()):
		var button = LevelButton.instance()
		var state = PlayerData.get("level_state")[i]
		button.setup(i, state)
		$CenterContainer/VBoxContainer/GridContainer.add_child(button)
		button.connect("onPressed", self, "onLevelButtonPressed")
		
	for i in range(0, PlayerData.get("keys")):
		var button = KeyButton.instance()
		button.connect("pressed", self, "onKeyPressed")
		$KeyBox.add_child(button)
		
func onLevelButtonPressed(button):
	var state = button.state
	var id = button.id
	if state == PlayerData.LevelState.Locked:
		return
	else:
		PlayerData.set("current_level", button.id)
		PlayerData.set("next_scene", "game")
		get_tree().change_scene_to(TransitionScene)
		
func onKeyPressed():
	var keys = PlayerData.get("keys")
	PlayerData.set("current_level", PlayerData.get("furthest_level"))
	PlayerData.completeCurrentLevel()
	PlayerData.get("level_state")[PlayerData.get("furthest_level") - 1] = PlayerData.LevelState.Skipped
	PlayerData.set("keys", keys - 1)
	get_tree().reload_current_scene()
