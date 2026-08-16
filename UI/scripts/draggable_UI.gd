extends Node
class_name DraggableUI

@export var bounds_buttons: Array[Button]
var held: bool = false
var last_mouse_pos: Vector2 = Vector2.INF

func _ready():
	for button in bounds_buttons:
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	for button in bounds_buttons:
		button.pressed.connect(button_pressed)

func _input(event: InputEvent):
	if event is not InputEventMouseMotion:
		return
	last_mouse_pos = event.relative

func _process(delta):
	if Input.is_action_just_released("select"):
		button_released()
	
	if !held:
		return
	
	get_parent().position += last_mouse_pos
	last_mouse_pos = Vector2.ZERO
	
func button_pressed() -> void:
	for button in bounds_buttons:
		button.mouse_default_cursor_shape = Control.CURSOR_DRAG
	held = true

func button_released() -> void:
	for button in bounds_buttons:
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	last_mouse_pos = Vector2.INF
	held = false
