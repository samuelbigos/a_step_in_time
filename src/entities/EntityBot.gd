extends EntityBase
class_name EntityBot

var _initialGridPos: Vector2
var _firstStep = true
var _botMove = Vector2(-1, 0)

var botMoveStack = []

func stepBegin():
	.stepBegin()
	_pendingMove = _botMove
		
func move(newGridPos: Vector2):
	var moveDelta = newGridPos - _gridPos
	.move(newGridPos)
	
	if moveDelta == Vector2():
		_botMove = _botMove * -1
		
	_sprite.flip_h = _botMove.x > 0
	
	botMoveStack.append(_botMove)
	
func _process(delta):
	pass
