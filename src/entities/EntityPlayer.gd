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
	
	# determine damage
	var groundEntity = grid.getAtFloor(getGridPos())
	if groundEntity and groundEntity.Traversible and groundEntity.Damage > 0:
		removeHeart()
		
	var hearts = get_tree().get_nodes_in_group("heart")
	var health = 0
	for heart in hearts:
		if not heart.isDestroyed():
			health += 1
			
	if health == 0:
		destroy()
		
func move(newGridPos):
	var moveDelta = newGridPos - _gridPos
	
	# determine meta mods
	var metas = get_tree().get_nodes_in_group("meta")
	for meta in metas:
		for connected in meta.connectedTo:
			
			var mod = 0
			match meta.metaType:
				EntityMeta.MetaType.X:
					mod = moveDelta.x
				EntityMeta.MetaType.Y:
					mod = -moveDelta.y
					
			match connected.metaType:
				EntityMeta.MetaType.Health:
					if mod > 0:
						while mod != 0:
							addHeart()
							mod -= 1
					if mod < 0:
						while mod != 0:
							removeHeart()
							mod += 1

	.move(newGridPos)
		
func removeHeart():
	var hearts = get_tree().get_nodes_in_group("heart")
	hearts.sort_custom(self, "heartSort")
	hearts[0].destroy()
	
func addHeart():
	var hearts = get_tree().get_nodes_in_group("heart")
	hearts.sort_custom(self, "heartSort")
	grid.addEntity(Grid.KEY_HEART, hearts[0].getGridPos() + Vector2(1, 0))

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
					var mod = -move.y
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

func heartSort(a, b):
	if a.getGridPos().x > b.getGridPos().x:
		return true
	return false
