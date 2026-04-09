extends Resource
class_name VoxelColorPalette

@export var name: String
@export var material: Material
@export var id: int
@export var colors: Dictionary[int, PaletteColor]
@export var color_order: Array[int]
@export var color_texture: ImageTexture

## Remove this eventually 
func _init():
	on_created()

func on_created() -> void:
	material = load("res://materials/color_palette.tres").duplicate()

func update_texture() -> void:
	var color_order: Array[Color]
	for id in colors:
		var color = colors[id]
		
		color.current_uv_index = color_order.size()
		color_order.append(color.color)
	
	var image = Image.new()
	for n in color_order.size():
		image.set_pixel(n, 0, color_order[n])
	
	color_texture.set_size_override(Vector2i(color_order.size(), 1))
	color_texture.create_from_image(image)
	
