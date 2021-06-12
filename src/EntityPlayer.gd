extends EntityBase
class_name EntityPlayer


func _ready():
	pass

func _process(delta):
	if Input.is_action_just_pressed("up"):
		_pendingMove = Vector2(0, -1)
	if Input.is_action_just_pressed("down"):
		_pendingMove = Vector2(0, 1)
	if Input.is_action_just_pressed("left"):
		_pendingMove = Vector2(-1, 0)
	if Input.is_action_just_pressed("right"):
		_pendingMove = Vector2(1, 0)
