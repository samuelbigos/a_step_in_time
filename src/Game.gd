extends Node2D

export var TransitionScene:= ""

onready var _grid = get_node("Grid")
onready var _noise = OpenSimplexNoise.new()

var disableMoves = false

var _restart = false
var _restartTimer = 0.5
var _joinTimer = 0.0
var _firstFrame = true
var _completedLevel = false
var _completeLevelTimer = 0.5

func _init():
	add_to_group("game")

func _ready():
	_noise.seed = randi()
	_noise.period = 4
	_noise.octaves = 2
		
	var moves = get_tree().get_nodes_in_group("move")
	disableMoves = moves.size() == 0
	
	$ElectricSFX.play()
	
func playDestroySFX():
	$DestroySFX.play()

func _process(delta):
	if _firstFrame:
		_firstFrame = false
		GlobalCamera.addTrauma(1.0)
		
	if _completedLevel:
		_completeLevelTimer -= delta
		if _completeLevelTimer < 0.0:
			PlayerData.completeCurrentLevel()
			get_tree().change_scene(TransitionScene)
		return
		
	if _restart:
		_restartTimer -= delta
		if _restartTimer < 0.0:
			get_tree().change_scene(TransitionScene)
			
	if Input.is_action_just_released("restart"):
		get_tree().change_scene(TransitionScene)
			
	var player = get_tree().get_nodes_in_group("player")
	if player.size() == 0:
		_restart = true
		return
		
	player = player[0]
	if player.isDestroyed():
		return
	
	var step = false
	if (Input.is_action_just_released("up") or 
		Input.is_action_just_released("down") or 
		Input.is_action_just_released("left") or 
		Input.is_action_just_released("right")):
		step = true
		
	if step:
		_grid.step()
			
	_joinTimer += delta * 50.0
	update()

func completeLevel():
	_completedLevel = true
	$FlagSFX.play()

func _draw():
	var metas = get_tree().get_nodes_in_group("meta")
	var processed = []
	var highestIntensity = 0.0
	for m1 in metas:
		processed.append(m1)
		for m2 in metas:
			if m1 == m2 or processed.has(m2):
				continue
			
			var p1 = m1.global_position
			var p2 = m2.global_position
			var length = (p1 - p2).length()
			if length > 125.0:
				continue
				
			p1 = p1 - (p1 - p2).normalized() * 5.0
			p2 = p2 - (p2 - p1).normalized() * 5.0
			var tangent = p2 - p1
			tangent = Vector2(tangent.y, -tangent.x)
			
			var segmentLen = 5.0
			var pointNum = (p1 - p2).length() / segmentLen
			var points = PoolVector2Array()
			var intensity = 1.0 - clamp((p2 - p1).length() / 150.0, 0.0, 1.0)
			
			highestIntensity = max(highestIntensity, intensity)
			
			var col = Color("caa05a")
			if m1.connectedTo.has(m2) or m2.connectedTo.has(m1):
				col = Color.white
			
			for i in range(pointNum + 1):
				var point = p1 + (p2 - p1) * i / pointNum
				var t = i / pointNum
				var noise = _noise.get_noise_2d(_joinTimer, t * 50.0)
				point += tangent.normalized() * noise * sin(_joinTimer + t * PI * 2.0) * segmentLen * intensity * 3.0
				points.push_back(point)
			draw_polyline(points, col, intensity * 5.0)
			
	$ElectricSFX.volume_db = lerp(-100, -25, highestIntensity)
