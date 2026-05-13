extends Node
class_name ColorSelectionInput

var manager: ColorPaletteManager
var palette_UIs: Dictionary[int, RadialMenu]

## Only for selecting colors with keys
@export var currently_selected_palette: int

func _ready():
	manager = get_node("%ColorPaletteManager")

func add_palette_UI(palette_id: int, menu: RadialMenu):
	palette_UIs[palette_id] = menu

	var colors: Dictionary[int, Color]
	var palette = manager.all_palettes[palette_id]
	
	for color_id in palette.color_order:
		colors[color_id] = palette.colors[color_id].color
	
	menu.make_children(colors)
	
	menu.on_press.connect(press_UI_button)

func press_UI_button(id: int) -> void:
	var selected = manager.currently_selected_colors.has(id)
	
	if Input.is_action_pressed("select_one"):
		if selected:
			deselect_color(id)
		else:
			select_color(id)
	elif Input.is_action_pressed("select_several"):
		select_color(id)
	else:
		deselect_all()
		select_color(id)
	
	print(manager.currently_selected_colors)

func deselect_all() -> void:
	var colors = manager.currently_selected_colors.duplicate()
	for color in colors:
		deselect_color(color)

func select_color(id: int) -> void:
	var palette = manager.palette_by_color[id]
	var index = manager.all_palettes[palette].color_order.find(id)
	
	if !manager.currently_selected_colors.has(id):
		manager.currently_selected_colors.append(id)
	if palette_UIs.has(palette):
		var ui_element: TextureButton = palette_UIs[palette].get_child(index)
		ui_element.set_instance_shader_parameter("black_replacement", UserPreferences.selection_color)
		ui_element.set_pressed_no_signal(true)
	
func deselect_color(id: int) -> void:
	var palette = manager.palette_by_color[id]
	var index = manager.all_palettes[palette].color_order.find(id)
	
	manager.currently_selected_colors.erase(id)
	if palette_UIs.has(palette):
		var ui_element: TextureButton = palette_UIs[palette].get_child(index)
		ui_element.set_instance_shader_parameter("black_replacement", UserPreferences.hover_color)
		ui_element.set_pressed_no_signal(false)
