extends EntityBase
class_name EntityHeart


func _ready():
	pass
	
func move(newGridPos):
	var moveDelta = newGridPos - _gridPos
	.move(newGridPos)
	
	# determine damage
#	var groundEntity = grid.getAtFloor(getGridPos())
#	if groundEntity and groundEntity.Traversible and groundEntity.Damage > 0:
#		groundEntity.queue_free()
#		queue_free()

func _process(delta):
	pass
