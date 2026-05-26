extends Control
class_name BrushSidebarUI

var paint_system: PaintSystem
@export var single_brush_scene: PackedScene
@export var add_brush_scene: PackedScene

func _ready():
	paint_system = ProjectManager.current_project.get_node("%PaintSystem")

func fill_list(brushes: Array[BaseBrush], per_line: int, max_lines: int, starting_y: int, item_width: int) -> void:
	var v_box = get_node("%VBoxContainer")
	var children = v_box.get_children()
	for child in children:
		child.queue_free()
	
	var current_hbox := HBoxContainer.new()
	current_hbox.add_theme_constant_override("separation", 2)
	v_box.add_child(current_hbox)
	var current_x: int = 0
	var current_y: int = 1
	
	var add_brush_node: Control = add_brush_scene.instantiate()
	var add_butt: Button = add_brush_node.get_node("%Button")
	add_butt.pressed.connect(paint_system.add_new_brush)
	current_hbox.add_child(add_brush_node)
	
	for brush in brushes:
		current_x += 1
		
		if current_x == per_line:
			current_x = 0
			current_hbox = HBoxContainer.new()
			current_hbox.add_theme_constant_override("separation", 2)
			v_box.add_child(current_hbox)
			v_box.move_child(current_hbox, 0)
			current_y += 1
		
		add_brush(brush, current_hbox)
	
	var lines: int = clamp(4, current_y, max_lines)
	
	## the scroll container gets fucked on new lines past the max but updating it isnt nice...
	size = Vector2(42.0 * per_line + 4.0, item_width * lines + 4.0)
	position.y = starting_y - item_width * lines - 6.0
	
	var margin = get_node("%MarginContainer")
	margin.size = Vector2(42.0 * per_line + 4.0, item_width * lines + 4.0)
	margin.position.y = 42.0 * max(4 - current_y, 0)
	
	var scroll: ScrollContainer = get_node("%ScrollContainer")
	if current_y > max_lines:
		scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_ALWAYS
	else:
		scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER

func add_brush(item: Resource, parent: Control) -> void:
	var brush_scene: Control = single_brush_scene.instantiate()
	parent.add_child(brush_scene)
	var texture: TextureRect = brush_scene.get_node("%Texture")
	var button: Button = brush_scene.get_node("%Button")
	paint_system.brush_UI_buttons[item.named_as] = button
	
	button.pressed.connect(paint_system.select_brush.bind(item.named_as))
	## uncomment when dynamic textures are a thing
	#texture.texture = BrushManager.get_brush_text(brush)
