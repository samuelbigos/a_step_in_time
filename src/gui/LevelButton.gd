extends TextureButton

var id = -1

signal onPressed


func setup(level, unlocked):
	id = level
	$Label.text = "%d" % (level + 1)
	$Label.visible = unlocked
	$Lock.visible = not unlocked

func _ready():
	modulate = Color("a7a79e")

func _on_TextureButton_pressed():
	emit_signal("onPressed", self)

func _on_TextureButton_mouse_entered():
	if $Lock.visible == false:
		modulate = Color("e0b94a")

func _on_TextureButton_mouse_exited():
	modulate = Color("a7a79e")
