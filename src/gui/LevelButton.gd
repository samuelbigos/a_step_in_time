extends TextureButton

var id = -1
var state = 0

signal onPressed


func setup(level, inState):
	id = level
	state = inState
	match state:
		0: $Lock.visible = true
		1: $Label.visible = true
		2: $Skipped.visible = true
		3: $Complete.visible = true
		
	$Label.text = "%d" % (id + 1)

func _ready():
	modulate = Color("a7a79e")

func _on_TextureButton_pressed():
	emit_signal("onPressed", self)

func _on_TextureButton_mouse_entered():
	if $Lock.visible == false:
		modulate = Color("e0b94a")

func _on_TextureButton_mouse_exited():
	modulate = Color("a7a79e")
