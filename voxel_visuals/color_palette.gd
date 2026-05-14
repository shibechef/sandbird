extends Resource
class_name VoxelColorPalette

@export var palette_name: String
@export var material: ShaderMaterial
@export var id: int
@export var colors: Dictionary[int, PaletteColor]
@export var color_order: Array[int]
@export var color_texture: ImageTexture

## Remove this eventually 
func _init():
	call_deferred("on_created")

func on_created() -> void:
	material = load("res://materials/color_palette.tres").duplicate()
	update_texture()

func update_texture() -> void:	
	material.set_shader_parameter("color_palette_tex", make_texture_for_shader())
	
func make_texture_for_UI() -> ImageTexture:
	for color_id in colors:
		var color = colors[color_id]
		color_order.append(color.color)
		
	var texture := ImageTexture.new()
	var image := Image.new()
	for n in colors.size():
		image.set_pixel(n, 0, colors[color_order[n]].color)
	
	texture.set_size_override(Vector2i(colors.size(), 1))
	texture = ImageTexture.create_from_image(image)
	
	return texture

func make_texture_for_shader() -> Texture2DArray:		
	var textures := Texture2DArray.new()
	var image := Image.new()
	
	var max_UV: int = 0
	for color_id in colors:
		var color: PaletteColor = colors[color_id]
		if color.current_uv_index > max_UV:
			max_UV = color.current_uv_index
			
	image = Image.create_empty(max_UV + 1, 1, false, Image.FORMAT_RGBF)
	
	for color_id in colors:
		var color: PaletteColor = colors[color_id]
		print(color.color)
		image.set_pixel(color.current_uv_index, 0, color.color)
	
	textures.create_from_images([image])
	
	return textures
