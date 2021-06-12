extends Area2D
class_name EntityBase

export var canMove:= false

onready var _sprite = get_node("Sprite")

var _pendingMove: Vector2
var _gridPos: Vector2

var grid: Object
var key = ""

func getGridPos(): return _gridPos
func getDesiredMove(): return _pendingMove
	
func stepBegin():
	pass
	
func stepEnd():
	_pendingMove = Vector2()
	
func move(newGridPos: Vector2):
	_gridPos = newGridPos
	updateWorldPos(_gridPos)
	
func updateWorldPos(_gridPos):
	global_position = grid.gridToWorld(_gridPos)

func _ready():
	var shape = RectangleShape2D.new()
	shape.extents.x = 8
	shape.extents.y = 8
	var shapeOwner = create_shape_owner(self)
	shape_owner_add_shape(shapeOwner, shape)
