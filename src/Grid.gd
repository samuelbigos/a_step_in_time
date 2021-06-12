extends Node2D

export var GridKeys = {}
export var GridCellSize := 16

var level1 = [
	[2,2,2,2,2,2,2,2,2,2],
	[2,0,0,0,0,0,0,0,0,2],
	[2,0,0,0,0,0,0,0,0,2],
	[2,0,0,1,0,0,0,0,0,2],
	[2,0,0,0,0,0,0,0,0,2],
	[2,0,0,0,0,0,3,0,0,2],
	[2,0,0,0,0,0,0,0,0,2],
	[2,0,0,0,0,0,0,0,0,2],
	[2,2,2,2,2,2,2,2,2,2],
]

var _gridHeight: int
var _gridWidth: int
var _origin: Vector2
var _gridEntities = {}


func _ready():
	var level = level1
	
	_gridHeight = level.size()
	_gridWidth = level[0].size()
	_origin = get_viewport_rect().size * 0.5 - Vector2(_gridWidth, _gridHeight) * 0.5 * GridCellSize
	for y in range(0, _gridHeight):
		for x in range(0, _gridWidth):
			var key = level[y][x]
			var gridPos = Vector2(x, y)
			if key != 0:
				var entity = GridKeys[level[y][x]].instance()
				add_child(entity)
				entity.global_position = _origin + Vector2(x, y) * GridCellSize
				_gridEntities[gridPos] = entity
				entity.grid = self
				entity.key = key
			else:
				_gridEntities[gridPos] = null
				
func step():
	# process entities in order of priority, using key to define priority
	# this allows a defined order of operations when processing the step, i.e.
	# player will block other entities when moving into the same square
	for i in range(0, GridKeys.size()):
		var key = i + 1
	
		for y in range(0, _gridHeight):
			for x in range(0, _gridWidth):
				var gridPos = Vector2(x, y)
				var entity = _gridEntities[gridPos]
				
				if not entity or entity.key != key:
					continue
					
				entity.stepBegin()
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
				line = line + "%d" % entity.key
			else:
				line = line + "0"
		print(line)
				
func _move(entity: Object, gridPos: Vector2, move: Vector2, depth: int) -> bool:
	if not entity.canMove or move == Vector2(0, 0):
		return false
		
	var targetGridPos = gridPos + move
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
