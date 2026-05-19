extends SidebarUI
class_name PaletteSidebarUI

@export var single_color_scene: PackedScene
@export var addition_scene: PackedScene
var color_selection: ColorSelectionInput
var palette_manager: ColorPaletteManager

func _ready():
	color_selection = ProjectManager.current_project.get_node("%ColorSelectionInput")
	palette_manager = ProjectManager.current_project.get_node("%ColorPaletteManager")

func add_item(item: Resource, parent: Control) -> void:
	var palette_scene: Control = item_scene.instantiate()
	parent.add_child(palette_scene)
	var grid: GridContainer = palette_scene.get_node("%GridContainer")
		
	## I like the + button being first so it doesn't move around
	var add_color_scene = addition_scene.instantiate()
	var add_butt: Button = add_color_scene.get_node("%Button")
	add_butt.pressed.connect(palette_manager.add_new_color.bind(item.id))
	grid.add_child(add_color_scene)
		
	for color_id: int in item.color_order:
		var palette_color: PaletteColor = item.colors[color_id]
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
	
