extends EntityMeta
class_name EntityMetaLevel


func _ready():
	$Sprite/Label.text = "%d" % (PlayerData.get("current_level") + 1)
	
func move(newGridPos):
	.move(newGridPos)

func _process(delta):
	pass
