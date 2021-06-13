extends Control

export var LevelButton: PackedScene
export var TransitionScene: PackedScene


func _ready():
	for i in range(0, Globals.Levels.size()):
		var button = LevelButton.instance()
		$CenterContainer/GridContainer.add_child(button)
		
		var unlocked = i <= PlayerData.get("unlocked_level")
		button.setup(i, unlocked)
		button.connect("onPressed", self, "onLevelButtonPressed")
		
func onLevelButtonPressed(button):
	PlayerData.set("current_level", button.id)
	PlayerData.set("next_scene", "game")
	get_tree().change_scene_to(TransitionScene)
