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
		
func stepEnd():
	.stepEnd()
	var health = get_tree().get_nodes_in_group("heart").size()
	if health == 0:
		destroy()
		
func destroy():
	_sprite.visible = false

func getDesiredMove():
	var move = .getDesiredMove()
	var moveMods = []
	
	# apply connection mods to movement
	var processed = []
	var metas = get_tree().get_nodes_in_group("meta")
	for meta in metas:
		for connected in meta.connectedTo:
			
			match meta.metaType:
				EntityMeta.MetaType.X:
					var mod = move.x
					match connected.metaType:
						EntityMeta.MetaType.X:
							if processed.has(meta):
								continue
							moveMods.append(Vector2(mod, 0))
							processed.append(connected)
						EntityMeta.MetaType.Y:
							moveMods.append(Vector2(0, mod))
							
				EntityMeta.MetaType.Y:
					var mod = move.y
					match connected.metaType:
						EntityMeta.MetaType.X:
							moveMods.append(Vector2(mod, 0))
						EntityMeta.MetaType.Y:
							if processed.has(meta):
								continue
							moveMods.append(Vector2(0, mod))
							processed.append(connected)
							
	for mod in moveMods:
		move += mod
	
	return move
