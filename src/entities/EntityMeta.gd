extends EntityBase
class_name EntityMeta

enum MetaType {
	X,
	Y,
	Health,
	Time,
	Moves,
	Level
}

export var metaType = MetaType.X

var connectedTo = []

var _baseCol = Color("a7a79e")
var _activeCol = Color("caa05a")
var _shakeTimer = 0.0


func _ready():
	add_to_group("meta")
	modulate = _baseCol

func _process(delta):
	if connectedTo.size() > 0:
		_shakeTimer += delta * 25.0		
		var s = sin(_shakeTimer) * 0.1 + 1.0
		_sprite.scale = Vector2(s, s)
		_sprite.rotation = sin(_shakeTimer * 2.0) * 0.125
	else:
		var s = 1.0
		_sprite.scale = Vector2(s, s)
		_sprite.rotation = 0.0
	
func stepEnd():
	.stepEnd()
	
	# determine connections
	connectedTo = []
	var dirs = [Vector2(0, 1), Vector2(0, -1), Vector2(1, 0), Vector2(-1, 0)]
	for dir in dirs:
		var n = grid.getAt(_gridPos + dir)
		if n and n.is_in_group("meta"):
			connectedTo.append(n)

	if connectedTo.size() > 0:
		modulate = _activeCol
	else:
		modulate = _baseCol
