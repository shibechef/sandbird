extends Node
class_name ColorPaletteManager

@export var palette_paths: Dictionary[String, String]
@export var all_palettes: Dictionary[int, VoxelColorPalette]
var palettes_by_order: Array[int]
## For finding which palette a color belongs to quickly
var palette_by_color: Dictionary[int, int]

var currently_selected_colors: Array[int]

func _ready():
	ready_palettes()

func add_new_color(palette: VoxelColorPalette) -> void:
	var id = randi()

	palette.colors[id].color = Color(randf(), randf(), randf())
	palette_by_color[id] = palette.id
	
	
	## Find the lowest UV index available
	var existing_UVs: Array[int]
	for color_id: int in palette.colors:
		existing_UVs.append(palette.colors[color_id].current_uv_index)
	existing_UVs.sort()
		
	for i in range(0, existing_UVs.size() - 1):
		var num = existing_UVs[i]
		if existing_UVs[i + 1] == num + 1:
			continue
		
		palette.colors[id].current_uv_index = num + 1
		break
		
func delete_color(palette: VoxelColorPalette, color_id: int) -> void:
	palette.colors.erase(color_id)
	palette_by_color.erase(color_id)

func add_existing_palette() -> void:
	return

func add_new_palette() -> void:
	var id = randi()
	
	var new_palette = VoxelColorPalette.new()
	var palette_name = "1"
	while all_palettes.has(palette_name):
		palette_name = str(int(palette_name) + 1)
	new_palette.name = palette_name
	new_palette.id = id
	
	all_palettes[id] = new_palette
	add_new_color(new_palette)

func delete_palette(palette_id: int) -> void:
	all_palettes.erase(palette_id)

func ready_palettes() -> void:
	palette_paths = FileReader.get_brushes()
	
	for palette_id in all_palettes:
		if !palettes_by_order.has(palette_id):
			palettes_by_order.append(palette_id)
		
		var palette = all_palettes[palette_id]
		for color_id in palette.colors:
			palette_by_color[color_id] = palette_id
