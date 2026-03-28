extends Node3D
class_name VoxelObject

@export var voxel_grid: Dictionary[Vector3i, VoxelData]
@export var dimensions: Vector3i
@export var outline_material = preload("res://materials/grid.tres")

var mesh_system: MeshSystem

func on_created() -> void:
	dimensions = get_node("%ScenePreferences").default_object_size

func _ready():
	mesh_system = get_node("%MeshSystem")
	
	dimensions = Vector3(2, 4, 8)
	var mesh_data = mesh_system.create_box(Vector3.ZERO, dimensions)
	var mesh_instance = mesh_system.create_mesh_instance(mesh_data[0], mesh_data[1])
	mesh_instance.mesh.surface_set_material(0, outline_material)
	add_child(mesh_instance)
