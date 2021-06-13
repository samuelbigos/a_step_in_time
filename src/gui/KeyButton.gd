extends TextureButton


func _ready():
	modulate = Color("cf6a4f")

func _on_KeyButton_mouse_entered():
	modulate = Color("e0b94a")

func _on_KeyButton_mouse_exited():
	modulate = Color("cf6a4f")
