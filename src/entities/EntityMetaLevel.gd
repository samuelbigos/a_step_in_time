extends EntityMeta
class_name EntityMetaLevel

export var TransitionScene: PackedScene


func _ready():
	$Sprite/Label.text = "%d" % (PlayerData.get("current_level") + 1)
	
func move(newGridPos):
	.move(newGridPos)

func _process(delta):
	pass

func _on_EntityMetaLevel_input_event(viewport, event, shape_idx):
	if event.is_action_released("click"):
		PlayerData.set("next_scene", "level_select")
		get_tree().change_scene_to(TransitionScene)

func _on_EntityMetaLevel_mouse_entered():
	modulate = Color("e0b94a")

func _on_EntityMetaLevel_mouse_exited():
	modulate = Color("a7a79e")
