extends Control
class_name HoverFocus

func _ready():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered():
	grab_focus()

func _on_mouse_exited():
	release_focus()
