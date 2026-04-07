extends Node
class_name ProjectPreferences

@export var default_object_size: Vector3i
@export var default_export_size: float

@export var mesh_chunk_size: int

@export var unselected_outline_color: Color
@export var selection_outline_color: Color
@export var outline_selection_width: float

func _ready():
	on_new_scene()

func on_new_scene() -> void:
	default_object_size = UserPreferences.default_object_size
	default_export_size = UserPreferences.default_export_size

	mesh_chunk_size = UserPreferences.mesh_chunk_size

	unselected_outline_color = UserPreferences.unselected_outline_color
	selection_outline_color = UserPreferences.selection_outline_color
	outline_selection_width = UserPreferences.outline_selection_width
