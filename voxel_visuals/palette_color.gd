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

func _init():
	call_deferred("update_hsv")
	call_deferred("update_hsl")

func update_hsv():
	hsv_saturation = color.s
	hsv_hue = color.h

func update_hsl():
	hsl_saturation = color.ok_hsl_s
	hsl_hue = color.ok_hsl_h
