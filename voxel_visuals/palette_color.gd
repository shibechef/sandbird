extends Resource
class_name PaletteColor

@export var color: Color
var id: int
var parent_id: int = -1
## Very sensitive, do not change or the vertex UVs do not match up
@export var current_uv_index: int
