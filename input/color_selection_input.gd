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

	var colors: Array[Color]
	var palette = manager.all_palettes[palette_id]
	
	for color_id in palette.color_order:
		colors.append(palette.colors[color_id].color)
	
	menu.make_children(colors)
	
	menu.on_press.connect(press_UI_button)

func press_UI_button(id: int) -> void:
	var selected = manager.currently_selected_colors.has(id)
	
	if Input.is_action_pressed("select_one"):
		if selected:
			manager.currently_selected_colors.erase(id)
		else:
			manager.currently_selected_colors.append(id)
	elif Input.is_action_pressed("select_several"):
		if !selected:
			manager.currently_selected_colors.append(id)
	else:
		manager.currently_selected_colors = [id]
	
	print(manager.currently_selected_colors)

func select_color(id: int) -> void:
	var palette: int = manager.palette_by_color[id]
	if palette_UIs.has(palette):
		var ui_element = palette_UIs[palette].get_child(id)
		ui_element.set_instance_shader_parameter("black_replacement", UserPreferences.selection_outline_color)

func deselect_color(id: int) -> void:
	var palette: int = manager.palette_by_color[id]
	if palette_UIs.has(palette):
		var ui_element = palette_UIs[palette].get_child(id)
		ui_element.set_instance_shader_parameter("black_replacement", UserPreferences.unselected_outline_color)
