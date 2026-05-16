extends Resource
class_name PaletteColor

@export var color: Color
@export var palette_id: int
@export var color_id: int
## Very sensitive, do not change or the vertex UVs do not match up
@export var current_uv_index: int
