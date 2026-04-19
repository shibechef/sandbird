extends Resource
class_name VoxelColorPalette

@export var palette_name: String
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
	color_texture = make_texture_for_shader()
	
func make_texture_for_UI() -> ImageTexture:
	for id in colors:
		var color = colors[id]
		color.current_uv_index = color_order.size()
		color_order.append(color.color)
		
	var texture := ImageTexture.new()
	var image := Image.new()
	for n in colors.size():
		image.set_pixel(n, 0, colors[color_order[n]].color)
	
	texture.set_size_override(Vector2i(colors.size(), 1))
	texture.create_from_image(image)
	
	return texture

func make_texture_for_shader() -> ImageTexture:		
	var texture := ImageTexture.new()
	var image := Image.new()
	for color_id in colors:
		var color = colors[color_id]
		image.set_pixel(color.current_uv_index, 0, color.color)
	
	texture.set_size_override(Vector2i(colors.size(), 1))
	texture.create_from_image(image)
	
	return texture
