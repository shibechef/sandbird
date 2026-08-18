extends Resource
class_name PaletteColor

@export var color: Color
@export var palette_id: int
@export var color_id: int
## Very sensitive, do not change or the vertex UVs do not match up
@export var current_uv_index: int

var hsv_hue: float
var hsv_saturation: float
var hsl_hue: float
var hsl_saturation: float

var palette_manager: ColorPaletteManager

func _init():
	call_deferred("late_ready")

func late_ready() -> void:
	palette_manager = ProjectManager.current_project.get_node("%ColorPaletteManager")
	update_hsv()
	update_hsl()

func update_material() -> void:
	print(color_id, " ", color.h, color.r)
	assert(palette_manager.all_palettes.has(palette_id), "palette ID " + str(palette_id) + " missing")
	palette_manager.all_palettes[palette_id].update_texture()

func update_hsv():
	hsv_saturation = clamp(color.s, .01, .99)
	hsv_hue = clamp(color.h, .01, .99)

func update_hsl():
	hsl_saturation = clamp(color.ok_hsl_s, .01, .99)
	hsl_hue = clamp(color.ok_hsl_h, .01, .99)
