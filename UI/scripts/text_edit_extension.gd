extends TextEdit
class_name TextEditExtension

func _input(event):
	if event.is_action("ui_text_submit"):
		release_focus()

func _unhandled_input(event):
	if event.is_action("select") or event.is_action("right_mouse"):
		release_focus()
