extends Control
class_name UITabExtension

@export var hide_on_enable: Array[Control]
@export var disable_on_enable: Array[Button]
@export var tab_button: Button
var hover_timer: float = 0.0
var hovered: bool = false
var hover_threshold: float = .35
var clipping_point: Vector2i 

var ui_manager: UI_manager

func _ready():
	hide()
	tab_button.pressed.connect(press_button)
	tab_button.mouse_entered.connect(on_hover)
	tab_button.mouse_exited.connect(on_stop_hover)
	ui_manager = ProjectManager.current_project.get_node("%UI_manager")
	UserPreferences.secondary_theme_set.connect(set_clipping_point.bind(Vector2i.ZERO))

func _process(delta):
	if hovered:
		hover_timer += delta
	if hover_timer > hover_threshold:
		extend(true)
		hover_timer = 0.0

func extend(auto_close: bool) -> void:
	show()
	tab_button.set_pressed_no_signal(true)
	hovered = false
	var parent = get_parent()
	var sidebar = get_sidebar()
	
	var new_pos = Vector2(sidebar.position.x + sidebar.size.x + size.x, parent.position.y)
	ui_manager.add_animation(parent, new_pos)
	
	for UI_object in hide_on_enable:
		UI_object.hide()
	
	for button in disable_on_enable:
		button.set_pressed_no_signal(false)

func detract() -> void:
	hovered = false
	tab_button.set_pressed_no_signal(false)
	var parent = get_parent()
	var sidebar = get_sidebar()
	var new_pos = Vector2(sidebar.position.x + sidebar.size.x, parent.position.y)
	ui_manager.add_animation(parent, new_pos, hide)

func press_button() -> void:
	if is_visible_in_tree():
		detract()
	else:
		extend(false)

func get_sidebar() -> Control:
	assert(false, name + " has no attached sidebar")
	return

func on_hover() -> void:
	hovered = true

func on_stop_hover() -> void:
	hover_timer = 0.0
	hovered = false

func set_clipping_point(start_pos: Vector2i) -> void:
	if material == null:
		return
	if start_pos == Vector2i.ZERO:
		start_pos = clipping_point
	material.set_shader_parameter("minimum_pos", start_pos)
	for child in get_children():
		if child.get("material") != null:
			child.material = child.material.duplicate()
			child.material.set_shader_parameter("minimum_pos", start_pos)
	clipping_point = start_pos
