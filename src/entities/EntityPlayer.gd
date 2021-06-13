extends EntityBase
class_name EntityPlayer


func _ready():
	_sprite.animation = "idle"
	_sprite.playing = true
	game = get_tree().get_nodes_in_group("game")[0]
	z_index = 1
	
func _process(delta):
	var moves = get_tree().get_nodes_in_group("move")
	if moves.size() > 0 or game.disableMoves:
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
		
func move(newGridPos):
	var moveDelta = newGridPos - _gridPos
	.move(newGridPos)
	
	var movesDelta = 0
	var heartDelta = 0
	
	# determine damage
	var damage = 0
	var groundEntity = grid.getAtFloor(getGridPos())
	if groundEntity and groundEntity.Traversible and groundEntity.Damage > 0:
		heartDelta -= 1
		damage += 1
		
	var moved = 0
	if moveDelta != Vector2():
		movesDelta -= 1
		moved += 1
	
	# determine meta mods
	var metas = get_tree().get_nodes_in_group("meta")
	for meta in metas:
		for connected in meta.connectedTo:
			
			var mod = 0
			match meta.metaType:
				EntityMeta.MetaType.X:
					mod = moveDelta.x
				EntityMeta.MetaType.Y:
					mod = moveDelta.y
				EntityMeta.MetaType.Health:
					mod = damage
				EntityMeta.MetaType.Moves:
					mod = moved
					
			match connected.metaType:
				EntityMeta.MetaType.Health:
					heartDelta += mod
				EntityMeta.MetaType.Moves:
					movesDelta += mod
				EntityMeta.MetaType.Level:
					if mod < 0:
						var level = PlayerData.get("current_level") - 1
						PlayerData.set("current_level", level)
						SaveManager.do_save()
						get_tree().change_scene("res://scenes/gui/ScreenTransition.tscn")
					elif mod > 0:
						game.completeLevel()
						
				EntityMeta.MetaType.Time:
					grid.timeMod = mod
			
	if movesDelta > 0 or heartDelta > 0:
		$AddHeartSFX.play()
		
	if heartDelta < 0:
		$HurtSFX.play()
				
	if heartDelta > 0:		
		while heartDelta != 0:
			addHeart()
			heartDelta -= 1
	else:
		while heartDelta != 0:
			removeHeart()
			heartDelta += 1
			
	if movesDelta > 0:
		while movesDelta != 0:
			addMove()
			movesDelta -= 1
	else:
		while movesDelta != 0:
			removeMove()
			movesDelta += 1
			
	# determine win
	if groundEntity and groundEntity.is_in_group("goal"):
		game.completeLevel()

	var hearts = get_tree().get_nodes_in_group("heart")
	var health = 0
	for heart in hearts:
		if not heart.isDestroyed():
			health += 1
			
	if health == 0:
		destroy()
		
	GlobalCamera.addTrauma(0.33)
	if moveDelta != Vector2():
		$MoveSFX.play()
		
func removeMove():
	var moves = get_tree().get_nodes_in_group("move")
	if moves.size() > 0:
		moves.sort_custom(self, "moveSort")
		moves[0].destroy()
	
func addMove():
	var moves = get_tree().get_nodes_in_group("move")
	moves.sort_custom(self, "moveSort")
	grid.addEntity(Grid.KEY_MOVE, moves[0].getGridPos() + Vector2(1, 0))
	
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

func heartSort(a, b):
	if a.getGridPos().x > b.getGridPos().x:
		return true
	return false

func moveSort(a, b):
	if a.getGridPos().x > b.getGridPos().x:
		return true
	return false
