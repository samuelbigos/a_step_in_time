extends Node2D

export var Decay = 3.5  # How quickly the shaking stops [0, 1].
export var MaxOffset = Vector2(0.04, 0.04)  # Maximum hor/ver shake in pixels.
export var MaxRoll = 0.125  # Maximum rotation in radians (use sparingly).
export var TraumaPower = 2 # Trauma exponent. Use [2, 3].
export var MaxTrauma = 0.75

onready var _noise = OpenSimplexNoise.new()

var _trauma = 0.0
var _player = null
var _noiseY = 0

enum WindowScale {
	Medium,
	Large,
	Full
}

var _windowScale = WindowScale.Medium


func addTrauma(trauma: float):
	_trauma = min(_trauma + trauma, MaxTrauma)
	
func _ready():
	MaxOffset = MaxOffset * get_viewport_rect().size
	randomize()
	_noise.seed = randi()
	_noise.period = 4
	_noise.octaves = 2
	
	get_viewport().canvas_transform = Transform2D(Vector2(1.0, 0.0), Vector2(0.0, 1.0), Vector2())

func _process(delta):
	var cameraTransform = Transform2D(Vector2(1.0, 0.0), Vector2(0.0, 1.0), Vector2(0.0, 0.0))
	
	if _trauma > 0.0:
		_trauma = max(_trauma - Decay * delta, 0.0)
		var amount = pow(_trauma, TraumaPower)
		var rot = MaxRoll * amount * _noise.get_noise_2d(_noise.seed, _noiseY)
		var offset = Vector2(0.0, 0.0)
		offset.x = MaxOffset.x * amount * _noise.get_noise_2d(_noise.seed * 2.0, _noiseY)
		offset.y = MaxOffset.y * amount * _noise.get_noise_2d(_noise.seed * 3.0, _noiseY)
		_noiseY += delta * 100.0
		
		cameraTransform.origin -= get_viewport().size * 0.5
		cameraTransform = cameraTransform.rotated(rot)
		cameraTransform = cameraTransform.translated(offset)
		cameraTransform.origin += get_viewport().size * 0.5
		
	get_viewport().canvas_transform = cameraTransform
	
#	if Input.is_action_just_released("fullscreen"):
#		match _windowScale:
#			WindowScale.Medium:
#				_windowScale = WindowScale.Large
#				OS.window_borderless = false
#				OS.set_window_size(Vector2(1920, 1080))
#			WindowScale.Large:
#				_windowScale = WindowScale.Full
#				OS.window_borderless = true
#				OS.set_window_size(OS.get_screen_size())
#				OS.set_window_position(Vector2(0, 0))
#			WindowScale.Full:
#				_windowScale = WindowScale.Medium
#				OS.window_borderless = false
#				OS.set_window_size(Vector2(960, 540))
