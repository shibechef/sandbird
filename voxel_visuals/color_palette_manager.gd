extends Node
class_name ColorPaletteManager

var all_palettes: Dictionary[String, VoxelColorPalette]
## For finding which palette a color belongs to quickly
var palette_by_color: Dictionary[int, String]

var currently_selected_palette: int
var currently_selected_UVs: Array[int]

func add_new_color(palette: VoxelColorPalette) -> void:
	var id = randi()
	while palette.has(id):
		id = randi()
	palette.colors[id] = Color(randf(), randf(), randf())
	palette_by_color[id] = palette.name

func delete_color(palette: VoxelColorPalette, color_id: int) -> void:
	palette.colors.erase(color_id)
	palette_by_color.erase(color_id)

func add_new_palette() -> void:
	var new_palette = VoxelColorPalette.new()
	var palette_name = "1"
	while all_palettes.has(palette_name):
		palette_name = str(int(palette_name) + 1)
	new_palette.name = palette_name
	all_palettes[palette_name] = new_palette
	
	add_new_color(new_palette)

func delete_palette(palette_id: int) -> void:
	all_palettes.erase(palette_id)

func swap_color_places() -> void:
	return

func change_palette_name(previous_name: String, new_name: String) -> void:
	var palette = all_palettes[previous_name]
	palette.name = new_name
	all_palettes.erase(previous_name)
	all_palettes[new_name] = palette
