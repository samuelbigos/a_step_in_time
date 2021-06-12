extends TextureButton

var id = -1

signal onPressed


func setup(level, unlocked):
	id = level
	$Label.text = "%d" % (level + 1)
	$Label.visible = unlocked
	$Lock.visible = not unlocked

func _ready():
	pass

func _on_TextureButton_pressed():
	emit_signal("onPressed", self)
