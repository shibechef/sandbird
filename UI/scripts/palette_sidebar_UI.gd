extends SidebarUI
class_name PaletteSidebarUI

@export var single_color_scene: PackedScene
var color_selection: ColorSelectionInput

func _ready():
	color_selection = ProjectManager.current_project.get_node("%ColorSelectionInput")

func add_item(item: Resource, parent: Control) -> void:
	var palette_scene: Control = item_scene.instantiate()
	parent.add_child(palette_scene)
	var grid: GridContainer = palette_scene.get_node("%GridContainer")
	
	## add a bunch of color buttons and a palette button
	
	for color_id: int in item.colors:
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
