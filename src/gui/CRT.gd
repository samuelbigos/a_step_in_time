extends CanvasLayer

var _timer = 0.0


func _process(delta):
	_timer += delta
	$TextureRect.material.set_shader_param("time", _timer)
