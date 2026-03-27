extends Node
class_name VoxelObject

@export var voxel_grid: Dictionary[Vector3i, VoxelData]
@export var pivot_point: Vector3i
@export var dimensions: Vector3i

func on_created() -> void:
	dimensions = get_node("%ScenePreferences").default_object_size
