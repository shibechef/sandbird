extends Node3D
class_name VoxelObject

@export var voxel_grid: Dictionary[Vector3i, VoxelData]
@export var dimensions: Vector3i = Vector3(32, 8, 16)
@export var outline_material = preload("res://materials/grid.tres")

@export var outline_object: Node3D

var project_preferences: ProjectPreferences
var mesh_system: MeshSystem

func on_created() -> void:
	dimensions = get_node("%ScenePreferences").default_object_size

func _ready():
	mesh_system = get_node("%MeshSystem")
	project_preferences = get_node("%ProjectPreferences")
	create_BB_outline()

func create_BB_outline():
	var mesh_data = mesh_system.create_box(Vector3.ZERO, dimensions)
	outline_object = mesh_system.create_mesh_instance(mesh_data[0], mesh_data[1])
	outline_material.set_shader_parameter("grid_color", project_preferences.unselected_outline_color)
	outline_material.set_shader_parameter("grid_size", dimensions)
	outline_material.set_shader_parameter("line_width", project_preferences.outline_selection_width)
	outline_object.mesh.surface_set_material(0, outline_material)
	add_child(outline_object)

func toggle_selection(selected: bool):
	if selected:
		outline_material.set_shader_parameter("grid_color", project_preferences.selection_outline_color)
	else:
		outline_material.set_shader_parameter("grid_color", project_preferences.unselected_outline_color)

func toggle_outline(on: bool):
	if on:
		outline_object.show()
	else:
		outline_object.hide()

func on_size_change():
	create_BB_outline()
