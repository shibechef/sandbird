extends Node
class_name ProjectPreferences

@export var default_object_size: Vector3i
@export var default_export_size: float

@export var mesh_chunk_size: int

func _ready():
	on_new_scene()

func on_new_scene() -> void:
	default_object_size = UserPreferences.default_object_size
	default_export_size = UserPreferences.default_export_size

	mesh_chunk_size = UserPreferences.mesh_chunk_size
