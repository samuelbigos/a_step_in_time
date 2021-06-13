extends Node2D
class_name Grid

export var GridCellSize := 16

const KEY_EMPTY = " "
const KEY_PLAYER = "P"
const KEY_GOAL = "G"
const KEY_WALL = "#"
const KEY_WATER = "W"
const KEY_LAVA = "L"
const KEY_BLOCK = "B"
const KEY_HEART = "3"
const KEY_META_X = "X"
const KEY_META_Y = "Y"
const KEY_META_HEALTH = "H"
const KEY_META_MOVES = "M"
const KEY_MOVE = "m"
const KEY_META_LEVEL = "l"
const KEY_META_TIME = "T"

var _gridKeys = {}
var _keyPrio = {}
var _gridHeight:= 16
var _gridWidth:= 30
var _origin: Vector2

var _gridEntities = {}
var _gridEntitiesFloor = {}

var _gridEntitiesStack = []
var _gridEntitiesFloorStack = []

func _ready():
	_gridKeys[KEY_EMPTY] = null
	_keyPrio[0] = KEY_EMPTY	
	_gridKeys[KEY_PLAYER] = load("res://scenes/entities/EntityPlayer.tscn")
	_keyPrio[1] = KEY_PLAYER	
	_gridKeys[KEY_WALL] = load("res://scenes/entities/EntityWall.tscn")
	_keyPrio[2] = KEY_WALL	
	_gridKeys[KEY_BLOCK] = load("res://scenes/entities/EntityBlock.tscn")
	_keyPrio[3] = KEY_BLOCK	
	_gridKeys[KEY_HEART] = load("res://scenes/entities/EntityHeart.tscn")
	_keyPrio[4] = KEY_HEART	
	_gridKeys[KEY_META_X] = load("res://scenes/entities/EntityMetaX.tscn")
	_keyPrio[5] = KEY_META_X	
	_gridKeys[KEY_META_Y] = load("res://scenes/entities/EntityMetaY.tscn")
	_keyPrio[6] = KEY_META_Y	
	_gridKeys[KEY_META_HEALTH] = load("res://scenes/entities/EntityMetaHealth.tscn")
	_keyPrio[7] = KEY_META_HEALTH	
	_gridKeys[KEY_META_MOVES] = load("res://scenes/entities/EntityMetaMoves.tscn")
	_keyPrio[8] = KEY_META_MOVES	
	_gridKeys[KEY_GOAL] = load("res://scenes/entities/EntityGoal.tscn")
	_keyPrio[9] = KEY_GOAL	
	_gridKeys[KEY_LAVA] = load("res://scenes/entities/EntityLava.tscn")
	_keyPrio[10] = KEY_LAVA	
	_gridKeys[KEY_MOVE] = load("res://scenes/entities/EntityMove.tscn")
	_keyPrio[11] = KEY_MOVE
	_gridKeys[KEY_META_LEVEL] = load("res://scenes/entities/EntityMetaLevel.tscn")
	_keyPrio[12] = KEY_META_LEVEL
	_gridKeys[KEY_META_TIME] = load("res://scenes/entities/EntityMetaTime.tscn")
	_keyPrio[12] = KEY_META_TIME
	_gridKeys[KEY_WATER] = load("res://scenes/entities/EntityWater.tscn")
	_keyPrio[13] = KEY_WATER
	
	var currentLevel = PlayerData.get("current_level")
	var level = Globals.Levels[currentLevel]
	
	#_gridHeight = level.size()
	#_gridWidth = level[0].length()
	_origin = get_viewport_rect().size * 0.5 - Vector2(_gridWidth, _gridHeight) * 0.5 * GridCellSize
	_origin += Vector2(GridCellSize, GridCellSize) * 0.5
	for y in range(0, _gridHeight):
		for x in range(0, _gridWidth):
			var gridPos = Vector2(x, y)
			var key = level[y][x]
			addEntity(key, gridPos)
			
func _process(delta):
	if Input.is_action_just_released("undo"):
		_undo()
		
func _undo():
	if _gridEntitiesStack.size() == 0:
		return
		
#	var lastStack = _gridEntitiesStack.size() - 1
#	for y in range(0, _gridHeight):
#		for x in range(0, _gridWidth):
#			if 
				
func addEntity(key, gridPos: Vector2):
	var entityScene = _gridKeys[key]
		
	if not _gridEntities.has(gridPos):
		_gridEntities[gridPos] = null
	if not _gridEntitiesFloor.has(gridPos):
		_gridEntitiesFloor[gridPos] = null
		
	if _gridEntities[gridPos]:
		_gridEntities[gridPos].destroy()
		
	if entityScene:
		var entity = entityScene.instance()
		add_child(entity)
		if entity.Traversible:
			_gridEntitiesFloor[gridPos] = entity
		else:
			_gridEntities[gridPos] = entity
		entity.grid = self
		entity.key = key
		entity._gridPos = gridPos
		entity.move(gridPos)
				
func getKey(level, pos: Vector2):
	var row = level[pos.y]
	var key = row[pos.x]
				
func step():
	_gridEntitiesStack.append(_gridEntities.duplicate())
	_gridEntitiesFloorStack.append(_gridEntitiesFloor.duplicate())
	
	for y in range(0, _gridHeight):
		for x in range(0, _gridWidth):
			var gridPos = Vector2(x, y)
			if not is_instance_valid(_gridEntities[gridPos]) or _gridEntities[gridPos].isDestroyed():
				_gridEntities[gridPos] = null
			if not is_instance_valid(_gridEntitiesFloor[gridPos]) or _gridEntitiesFloor[gridPos].isDestroyed():
				_gridEntitiesFloor[gridPos] = null
			
			var entity = _gridEntities[gridPos]
			if entity:
				entity.stepBegin()
				
	# process entities in order of priority, using key to define priority
	# this allows a defined order of operations when processing the step, i.e.
	# player will block other entities when moving into the same square
	for i in range(0, _keyPrio.size()):
		var key = _keyPrio[i]
	
		for y in range(0, _gridHeight):
			for x in range(0, _gridWidth):
				var gridPos = Vector2(x, y)
				var entity = _gridEntities[gridPos]
				
				if not entity or entity.key != key:
					continue
				
				var move = entity.getDesiredMove()
				var didMove = _move(entity, gridPos, move, 0)
				
				while not didMove:
					if  move.length() > 1 and abs(move.x) > abs(move.y):
						move.x -= sign(move.x)
						didMove = _move(entity, gridPos, move, 0)
					elif move.length() > 1 and abs(move.y) > abs(move.x):
						move.y -= sign(move.y)
						didMove = _move(entity, gridPos, move, 0)
					elif move.length() > 1 and abs(move.x) == abs(move.y) and abs(move.x) > 1:
						move.x -= sign(move.x)
						didMove = _move(entity, gridPos, move, 0)
					elif abs(move.x) == 1 and abs(move.y) == 1:
						didMove = _move(entity, gridPos, Vector2(move.x, 0), 0)
						didMove = didMove or _move(entity, gridPos, Vector2(0, move.y), 0)
						break
					else:
						break
						
				entity.consumeMove()
	
	for y in range(0, _gridHeight):
		for x in range(0, _gridWidth):
			var gridPos = Vector2(x, y)
			var entity = _gridEntities[gridPos]
			if entity:
				entity.move(gridPos)
				
	for y in range(0, _gridHeight):
		for x in range(0, _gridWidth):
			var gridPos = Vector2(x, y)
			var entity = _gridEntities[gridPos]
			if entity:
				entity.stepEnd()
				
func _move(entity: Object, gridPos: Vector2, move: Vector2, depth: int) -> bool:
	if not entity.is_in_group("player"):
		move.x = sign(move.x)
		move.y = sign(move.y)
	
	if not entity.CanMove or move == Vector2(0, 0):
		return false
		
	var targetGridPos = gridPos + move
	if (targetGridPos.x < 0 or targetGridPos.x >= _gridWidth or 
		targetGridPos.y < 0 or targetGridPos.y >= _gridHeight):
		return false
	
	var targetEntity = _gridEntities[targetGridPos]
		
	if not targetEntity:
		_gridEntities[gridPos] = null
		_gridEntities[targetGridPos] = entity
		return true
	else:
		var canMove: bool
		if entity.is_in_group("player") and not targetEntity.PlayerMovable:
			canMove = false
		else:
			canMove = _move(targetEntity, targetGridPos, move, depth + 1)
			
		if canMove:
			_gridEntities[gridPos] = null
			_gridEntities[targetGridPos] = entity
			return true
		else:
			return false

func gridToWorld(gridPos: Vector2) -> Vector2:
	return _origin + gridPos * GridCellSize

func getAt(gridPos: Vector2):
	if _gridEntities.has(gridPos):
		return _gridEntities[gridPos]
	return null
	
func getAtFloor(gridPos: Vector2):
	return _gridEntitiesFloor[gridPos]
