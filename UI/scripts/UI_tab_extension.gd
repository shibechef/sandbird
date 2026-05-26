extends Control
class_name UITabExtension

@export var tab_button: Button
var hover_timer: float = 0.0
var hovered: bool = false
var hover_threshold: float = .35

var ui_manager: UI_manager

func _ready():
	material = material.duplicate()
	tab_button.pressed.connect(extend.bind(false))
	tab_button.mouse_entered.connect(on_hover)
	tab_button.mouse_exited.connect(on_stop_hover)
	ui_manager = get_parent().get_parent()

func _process(delta):
	if hovered:
		hover_timer += delta
	if hover_timer > hover_threshold:
		extend(true)
		hover_timer = 0.0

func extend(auto_close: bool) -> void:
	hovered = false
	var parent = get_parent()
	var sidebar = get_sidebar()
	var new_pos = Vector2(sidebar.position.x + sidebar.size.x + size.x, parent.position.y)
	ui_manager.add_animation(parent, new_pos)

func get_sidebar() -> Control:
	assert(false, name + " has no attached sidebar")
	return

func on_hover() -> void:
	hovered = true

func on_stop_hover() -> void:
	hover_timer = 0.0
	hovered = false

func set_clipping_point(start_pos: Vector2i) -> void:
	print(start_pos)
	material.set_shader_parameter("minimum_pos", start_pos)
