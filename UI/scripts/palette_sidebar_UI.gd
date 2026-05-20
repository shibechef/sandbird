extends Control
class_name PaletteSidebarUI

@export var palette_spacing: int
@export var single_palette_scene: PackedScene
@export var single_color_scene: PackedScene
@export var add_color_scene: PackedScene
@export var add_palette_scene: PackedScene
var color_selection: ColorSelectionInput
var palette_manager: ColorPaletteManager

func _ready():
	color_selection = ProjectManager.current_project.get_node("%ColorSelectionInput")
	palette_manager = ProjectManager.current_project.get_node("%ColorPaletteManager")

func fill_list(palettes: Array[VoxelColorPalette]) -> void:
	var v_box = get_node("%VBoxContainer")
	v_box.add_theme_constant_override("separation", palette_spacing)
	
	var children = v_box.get_children()
	for child in children:
		child.queue_free()
	
	for palette in palettes:
		add_palette(palette, v_box)
	
	var add_new_palette = add_palette_scene.instantiate()
	v_box.add_child(add_new_palette)
	var add_butt: Button = add_new_palette.get_node("%Button")
	add_butt.pressed.connect(palette_manager.add_new_palette)

func add_palette(palette: VoxelColorPalette, parent: Control) -> void:
	var palette_scene: Control = single_palette_scene.instantiate()
	parent.add_child(palette_scene)
	var grid: GridContainer = palette_scene.get_node("%GridContainer")
		
	## I like the + button being first so it doesn't move around
	var add_color_node = add_color_scene.instantiate()
	var add_butt: Button = add_color_node.get_node("%Button")
	add_butt.pressed.connect(palette_manager.add_new_color.bind(palette.id))
	grid.add_child(add_color_node)
		
	for color_id: int in palette.color_order:
		var palette_color: PaletteColor = palette.colors[color_id]
		var color_scene = single_color_scene.instantiate()
		grid.add_child(color_scene)
		var rect: TextureRect = color_scene.get_node("%Texture")
		var text: GradientTexture1D = GradientTexture1D.new()
		text.gradient = Gradient.new()
		text.gradient.set_color(0, palette_color.color)
		text.width = 1
		rect.texture = text
		
		var butt: Button = color_scene.get_node("%Button")
		butt.pressed.connect(color_selection.select_color.bind(color_id))
	
