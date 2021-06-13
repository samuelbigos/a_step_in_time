extends EntityBase
class_name EntityWater

var _initialGridPos: Vector2
var _firstStep = true


func stepBegin():
	.stepBegin()
	
	if _firstStep:
		_firstStep = false
		_initialGridPos = _gridPos
		
	if _gridPos == _initialGridPos:
		_pendingMove = Vector2(0, 1)
	
func _process(delta):
	pass
