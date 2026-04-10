extends Node
class_name ColorPaletteManager

@export var all_palettes: Dictionary[int, VoxelColorPalette]
var palettes_by_order: Array[int]
## For finding which palette a color belongs to quickly
var palette_by_color: Dictionary[int, int]

var currently_selected_colors: Array[int]
## Only for selecting colors with keys
## Also maybe have UI showing color numbers after selecting a palette
@export var currently_selected_palette: int

func _ready():
	for palette_id in all_palettes:
		if !palettes_by_order.has(palette_id):
			palettes_by_order.append(palette_id)
		
		var palette = all_palettes[palette_id]
		for color_id in palette.colors:
			palette_by_color[color_id] = palette_id

	var first_palette = all_palettes[palettes_by_order[0]]
	currently_selected_colors.append(first_palette.color_order[0])

func get_current_color() -> int:
	return currently_selected_colors[randi_range(0, currently_selected_colors.size() - 1)]

func add_new_color(palette: VoxelColorPalette) -> void:
	var id = randi()

	palette.colors[id].color = Color(randf(), randf(), randf())
	palette_by_color[id] = palette.id

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
	
	all_palettes[id] = new_palette
	add_new_color(new_palette)

func delete_palette(palette_id: int) -> void:
	all_palettes.erase(palette_id)
