extends Node3D
class_name VoxelObject

@export var voxel_grid: Dictionary[Vector3i, VoxelData]
@export var dimensions: Vector3i
@export var outline_material = preload("res://materials/grid.tres")

@export var outline_object: Node3D

@export var visual_mesh_grids: Dictionary[Vector3i, ArrayMesh]
@export var visual_offset: Vector3i

var project_prefs: ProjectPreferences
var mesh_system: MeshSystem

func on_created() -> void:
	dimensions = project_prefs.default_object_size

func _ready():	
	mesh_system = get_parent().get_node("%MeshSystem")
	project_prefs = get_parent().get_node("%ProjectPreferences")
	outline_material = outline_material.duplicate()
	
	if dimensions == Vector3i.ZERO:
		dimensions = project_prefs.default_object_size
	
	create_BB_outline()
	
	if !voxel_grid.is_empty():
		mesh_system.generate_chunk_meshes(dimensions, voxel_grid)

func create_BB_outline() -> void:
	var mesh_data = mesh_system.create_box(Vector3.ZERO, dimensions)
	outline_object = mesh_system.create_mesh_instance(mesh_data)
	outline_material.set_shader_parameter("grid_color", project_prefs.unselected_outline_color)
	outline_material.set_shader_parameter("grid_size", dimensions)
	outline_material.set_shader_parameter("line_width", project_prefs.outline_selection_width)
		
	outline_object.mesh.surface_set_material(0, outline_material)
	add_child(outline_object)

func on_size_change() -> void:
	## Needs to change the mesh offset
	
	create_BB_outline()
	
func toggle_selection(selected: bool) -> void:
	## Need to redo all effected edge chunk meshes
	
	if selected:
		outline_material.set_shader_parameter("grid_color", project_prefs.selection_outline_color)
	else:
		outline_material.set_shader_parameter("grid_color", project_prefs.unselected_outline_color)
	outline_object.mesh.surface_set_material(0, outline_material)

func toggle_outline(on: bool) -> void:
	if on:
		outline_object.show()
	else:
		outline_object.hide()

func edit_voxel(coords: Vector3i, material: Material, unique: bool = true):
	return
