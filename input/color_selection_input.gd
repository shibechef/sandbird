extends Node
class_name ColorSelectionInput

var manager: ColorPaletteManager
var palette_UIs: Dictionary[int, RadialMenu]

## Only for selecting colors with keys
@export var currently_selected_palette: int

func add_palette_UI(palette: int, menu: RadialMenu):
	palette_UIs[palette] = menu
	menu.on_press.connect(press_UI_button)

func press_UI_button(id: int) -> void:
	print(id)
	if Input.is_action_pressed("select_one"):
		return
	if Input.is_action_just_pressed("select_several"):
		return

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
