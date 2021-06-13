extends Area2D
class_name EntityBase

export var PlayerMovable:= true
export var CanMove:= false
export var Traversible:= false
export var Temporal:= false
export var Damage:= 0
export var Animate:= false
export var MoveAnimTime = 0.125

onready var _sprite = get_node("Sprite")

var _moveFrom: Vector2
var _moving = false
var _moveTimer = 0.0

var _pendingMove: Vector2
var _gridPos: Vector2
var _destroyed:= false
var _destroyTimer = 1.0
var _animTimer = 0.0
var _moveSFX = AudioStreamPlayer.new()

var game: Object
var grid: Object
var key = ""
var positionStack = []

func getGridPos(): return _gridPos
func getDesiredMove(): return _pendingMove
func isDestroyed(): return _destroyed
	
func stepBegin():
	pass
	
func stepEnd():
	pass
	
func consumeMove():
	_pendingMove = Vector2()
	
func move(newGridPos: Vector2):
	var moveDelta = newGridPos - _gridPos
	if moveDelta != Vector2():
		_moving = true
		_moveTimer = MoveAnimTime
		_moveFrom = newGridPos - moveDelta
		if abs(moveDelta.x) > 0:
			_sprite.flip_h = moveDelta.x < 0
			
		if key != "P" and key != "W":
			_moveSFX.play()
			
	updateWorldPos(_gridPos)
	_gridPos = newGridPos
	positionStack.append(_gridPos)	
	
func updateWorldPos(gridPos):
	global_position = grid.gridToWorld(gridPos)
	
func destroy():
	_destroyed = true
	_sprite.visible = false
	queue_free()
	if key != "P" and key != "m":
		game.playDestroySFX()
	
func _ready():
	var shape = RectangleShape2D.new()
	shape.extents.x = 8
	shape.extents.y = 8
	var shapeOwner = create_shape_owner(self)
	shape_owner_add_shape(shapeOwner, shape)
	add_to_group("entity")
	z_index = -1
	add_child(_moveSFX)
	_moveSFX.stream = load("res://assets/sfx/push.wav")
	_moveSFX.volume_db = -5	
	game = get_tree().get_nodes_in_group("game")[0]

func _process(delta):
	if Animate:
		_animTimer += delta * 2.5
		#_sprite.rotation = sin(_animTimer * 2.0) * 0.25
		#var s = sin(_animTimer) * 0.25 + 1.0
		#_sprite.scale = Vector2(s, s)
	
	if _moving:
		_moveTimer -= delta
		var t = (MoveAnimTime - _moveTimer) / MoveAnimTime
		global_position = grid.gridToWorld(lerp(_moveFrom, _gridPos, ease(t, -2.5)))
		if _moveTimer < 0.0:
			_moving = false
			#_sprite.animation = "idle"
			global_position = grid.gridToWorld(_gridPos)
