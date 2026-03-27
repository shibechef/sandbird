extends Node3D
class_name VoxelObject

@export var voxel_grid: Dictionary[Vector3i, VoxelData]
@export var dimensions: Vector3i

var mesh_system: MeshSystem

func on_created() -> void:
	dimensions = get_node("%ScenePreferences").default_object_size

func _ready():
	mesh_system = get_node("%MeshSystem")
	
	dimensions = Vector3(3, 3, 3)
	var mesh_data = mesh_system.create_box(Vector3.ZERO, dimensions)
	var mesh_instance = mesh_system.create_mesh_instance(mesh_data[0], mesh_data[1])

	add_child(mesh_instance)
