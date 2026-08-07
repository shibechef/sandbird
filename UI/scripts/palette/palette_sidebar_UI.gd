extends Control
class_name PaletteSidebarUI

@export var palette_spacing: int
@export var single_palette_scene: PackedScene
@export var single_color_scene: PackedScene
@export var add_color_scene: PackedScene
@export var add_palette_scene: PackedScene

var color_selection: ColorSelectionInput
var palette_manager: ColorPaletteManager
var palette_properties: PalettePropertiesTab
var ui_manager: UI_manager

func _ready():
	color_selection = get_node("%ColorSelectionInput")
	palette_manager = get_node("%ColorPaletteManager")
	palette_properties = get_node("%ExtendedPaletteSidebarUI").get_node("%PalettePropertiesTab")
	ui_manager = get_node("%UI_manager")

func fill_list(palettes: Array[VoxelColorPalette], per_line: int) -> void:
	var v_box = get_node("%VBoxContainer")
	v_box.add_theme_constant_override("separation", palette_spacing)
	
	var children = v_box.get_children()
	for child in children:
		child.queue_free()
	
	for palette in palettes:
		add_palette(palette, v_box, per_line)
	
	var add_new_palette = add_palette_scene.instantiate()
	v_box.add_child(add_new_palette)
	var add_butt: Button = add_new_palette.get_node("%Button")
	add_butt.pressed.connect(palette_manager.add_new_palette)
	
	size.x = per_line * 24 + 8

func add_palette(palette: VoxelColorPalette, parent: Control, per_line: int) -> void:
	var palette_scene: Control = single_palette_scene.instantiate()
	parent.add_child(palette_scene)
	var grid: GridContainer = palette_scene.get_node("%GridContainer")
	grid.columns = per_line
	
	var name_button: Button = palette_scene.get_node("%NameButton")
	name_button.name = palette.palette_name
	name_button.pressed.connect(palette_properties.open_and_fill.bind(palette))	
	name_button.pressed.connect(ui_manager.palette_import_tab.export_item_clicked.bind(palette))	
	
	## I like the + button being first so it doesn't move around
	var add_color_node = add_color_scene.instantiate()
	var add_butt: Button = add_color_node.get_node("%Button")
	add_butt.pressed.connect(palette_manager.add_new_color.bind(palette.id))
	grid.add_child(add_color_node)
	
	var lines = ceili((palette.colors.size() + 1) / float(per_line))
	palette_scene.custom_minimum_size.y = lines * 22 + 22
	
	for color_id: int in palette.color_order:
		var palette_color: PaletteColor = palette.colors[color_id]
		var color: Color = palette_color.color
		var color_scene = single_color_scene.instantiate()
		grid.add_child(color_scene)
		var rect: TextureRect = color_scene.get_node("%Texture")
		rect.texture = get_gradient_text(color)
		
		var butt: TextureButton = color_scene.get_node("%Button")
		color_selection.color_buttons[color_id] = butt
		butt.texture_normal = get_gradient_text(lerp(color, Color.DIM_GRAY, .5))
		butt.texture_pressed = get_gradient_text(UserPreferences.hover_color)
		butt.texture_hover = get_gradient_text(UserPreferences.selection_color)
		butt.pressed.connect(color_selection.press_UI_button.bind(color_id))

func get_gradient_text(color: Color) -> GradientTexture1D:
	var text: GradientTexture1D = GradientTexture1D.new()
	text.gradient = Gradient.new()
	text.gradient.set_color(0, color)
	text.width = 1

	return text
