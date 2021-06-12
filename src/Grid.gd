extends Node2D

export var GridCellSize := 16

const KEY_EMPTY = " "
const KEY_PLAYER = "P"
const KEY_GOAL = "G"
const KEY_WALL = "#"
const KEY_BLOCK = "B"
const KEY_HEART = "3"
const KEY_X = "X"
const KEY_Y = "Y"

var _gridKeys = {}
var _keyPrio = {}
var _gridHeight: int
var _gridWidth: int
var _origin: Vector2
var _gridEntities = {}

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
	
	_gridKeys[KEY_X] = load("res://scenes/entities/EntityMetaX.tscn")
	_keyPrio[5] = KEY_X
	
	_gridKeys[KEY_Y] = load("res://scenes/entities/EntityMetaY.tscn")
	_keyPrio[6] = KEY_Y
	
	_gridKeys[KEY_GOAL] = load("res://scenes/entities/EntityGoal.tscn")
	_keyPrio[7] = KEY_GOAL
	
	var currentLevel = PlayerData.get("current_level")
	var level = Globals.Levels[currentLevel]
	
	_gridHeight = level.size()
	_gridWidth = level[0].length()
	_origin = get_viewport_rect().size * 0.5 - Vector2(_gridWidth, _gridHeight) * 0.5 * GridCellSize
	_origin += Vector2(GridCellSize, GridCellSize) * 0.5
	for y in range(0, _gridHeight):
		for x in range(0, _gridWidth):
			var gridPos = Vector2(x, y)
			var key = level[y][x]
			var entityScene = _gridKeys[key]
			if entityScene:
				var entity = entityScene.instance()
				add_child(entity)
				_gridEntities[gridPos] = entity
				entity.grid = self
				entity.key = key
				entity.move(gridPos)
			else:
				_gridEntities[gridPos] = null
				
func getKey(level, pos: Vector2):
	var row = level[pos.y]
	var key = row[pos.x]
				
func step():
	for y in range(0, _gridHeight):
		for x in range(0, _gridWidth):
			var gridPos = Vector2(x, y)
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
				_move(entity, gridPos, move, 0)
				entity.stepEnd()
	
	print("-")
	for y in range(0, _gridHeight):
		var line = ""
		for x in range(0, _gridWidth):
			var gridPos = Vector2(x, y)
			var entity = _gridEntities[gridPos]
			if entity:
				entity.move(gridPos)
				entity.stepEnd()
				line = line + "%s" % entity.key
			else:
				line = line + "0"
		print(line)
				
func _move(entity: Object, gridPos: Vector2, move: Vector2, depth: int) -> bool:
	if not entity.canMove or move == Vector2(0, 0):
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
		var canMove = _move(targetEntity, targetGridPos, move, depth + 1)
		if canMove:
			_gridEntities[gridPos] = null
			_gridEntities[targetGridPos] = entity
			return true
		else:
			return false

func gridToWorld(gridPos: Vector2) -> Vector2:
	return _origin + gridPos * GridCellSize

func getAt(gridPos: Vector2):
	return _gridEntities[gridPos]
