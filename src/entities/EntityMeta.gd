extends EntityBase
class_name EntityMeta

enum MetaType {
	X,
	Y,
	Health,
	Time,
	Moves
}

export var metaType = MetaType.X

var connectedTo = []


func _ready():
	add_to_group("meta")

func _process(delta):
	pass
	
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
		modulate = Color.yellow
	else:
		modulate = Color.white
