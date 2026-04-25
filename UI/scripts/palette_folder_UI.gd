extends Control

var palettes: Dictionary
@export var colors_per_line: int = 20
@export var palette_constant_length: int = 2
## Make this adjustable!
@export var pixel_width: float = 40.0 

var v_box: VBoxContainer
var palette_UI_scene: String = "res://UI/scripts/palette_folder_UI.gd"

func _ready():
	v_box = get_node("%VBox")
	refresh_available_brushes()
	refresh_UI()
	
func refresh_available_brushes() -> void:
	palettes = FileReader.get_palettes()

func refresh_UI() -> void:
	var children = v_box.get_children()
	for child in children:
		child.queue_free()
	
	var current_horizontal_length: int = 0
	var current_line: int = 0

	for palette_name in palettes:
		var path = palettes[palette_name]
		var palette: VoxelColorPalette = load(path)
		var palette_size = palette.colors.keys().size() + palette_constant_length
		
		if current_horizontal_length != 0 and current_horizontal_length + palette_size > colors_per_line:
			current_line += 1
			v_box.add_child(HBoxContainer.new())
			
		var h_box: HBoxContainer = v_box.get_child(current_line)
		
		var palette_UI = load(palette_UI_scene)
		var texture = palette_UI.get_node("%Texture")
		
		texture.texture = palette.make_texture_for_UI()
		
		add_child(palette_UI)
		
		print(palette.colors)
