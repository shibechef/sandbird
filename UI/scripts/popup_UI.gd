extends Control
class_name PopupUI

func _input(event):
	if event.is_action_pressed("close_UI"):
		close_UI()

func open_UI() -> void:
	## animate opacity
	show()

func close_UI() -> void:
	## maybe lower the opacity
	## also sort by highest priority/most recently opened popup
	hide()
