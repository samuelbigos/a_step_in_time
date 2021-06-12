extends Area2D
class_name EntityBase

export var CanMove:= false
export var Traversible:= false
export var Damage:= 0

onready var _sprite = get_node("Sprite")

var _pendingMove: Vector2
var _gridPos: Vector2
var _destroyed:= false
var _destroyTimer = 1.0

var grid: Object
var key = ""

func getGridPos(): return _gridPos
func getDesiredMove(): return _pendingMove
func isDestroyed(): return _destroyed
	
func stepBegin():
	pass
	
func stepEnd():
	_pendingMove = Vector2()
	
func move(newGridPos: Vector2):
	_gridPos = newGridPos
	updateWorldPos(_gridPos)
	
func updateWorldPos(_gridPos):
	global_position = grid.gridToWorld(_gridPos)
	
func destroy():
	_destroyed = true
	_sprite.visible = false
	queue_free()
	
func _ready():
	var shape = RectangleShape2D.new()
	shape.extents.x = 8
	shape.extents.y = 8
	var shapeOwner = create_shape_owner(self)
	shape_owner_add_shape(shapeOwner, shape)
	add_to_group("entity")

func _process(delta):
	pass
