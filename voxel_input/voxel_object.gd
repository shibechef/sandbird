extends Node3D
class_name VoxelObject

@export var voxel_grid: Dictionary[Vector3i, VoxelData]
var previous_grid: Dictionary[Vector3i, VoxelData]
var consecutive_changes: Dictionary[Vector3i, VoxelData]
@export var dimensions: Vector3i
@export var outline_material = preload("res://materials/grid.tres")

@export var outline_object: Node3D

var visual_mesh_chunks: Dictionary[Vector3i, MeshInstance3D]
var visual_offset: Vector3i
var edited_chunks: Array[Vector3i]

var mutex: Mutex

var project_prefs: ProjectPreferences
var mesh_system: MeshSystem
var collision_system: CollisionSystem

func on_created() -> void:
	dimensions = project_prefs.default_object_size

func _process(delta):
	update_mesh_chunks()

func _ready():		
	mutex = Mutex.new()
	mesh_system = get_parent().get_node("%MeshSystem")
	project_prefs = get_parent().get_node("%ProjectPreferences")
	collision_system = get_parent().get_node("%CollisionSystem")
	
	outline_material = outline_material.duplicate()
	
	if dimensions == Vector3i.ZERO:
		dimensions = project_prefs.default_object_size
	
	create_BB_outline()
	
func update_mesh_chunks() -> void:
	var id = WorkerThreadPool.add_group_task(update_chunk_visual, edited_chunks.size())
	WorkerThreadPool.wait_for_group_task_completion(id)
	edited_chunks.clear()

func update_chunk_visual(chunk_index) -> void:	
	var chunk: Vector3i = edited_chunks[chunk_index]
	var is_new_chunk: bool = !visual_mesh_chunks.has(chunk)
	
	var AABB_lower: Vector3i = visual_offset + chunk * project_prefs.mesh_chunk_size
	var AABB_upper: Vector3i = AABB_lower + Vector3i.ONE * project_prefs.mesh_chunk_size
	
	var mesh_instance: MeshInstance3D
	mutex.lock()
	if !visual_mesh_chunks.has(chunk):
		visual_mesh_chunks[chunk] = MeshInstance3D.new()
	mesh_instance = visual_mesh_chunks[chunk]
	mutex.unlock()
	
	mesh_instance.call_thread_safe("set", "mesh", mesh_system.get_chunk_mesh(AABB_lower, AABB_upper, voxel_grid, visual_offset).mesh)
	
	if is_new_chunk:
		call_thread_safe("add_child", visual_mesh_chunks[chunk])

func get_only_changed(voxels: Dictionary[Vector3i, VoxelData]) -> Dictionary[Vector3i, VoxelData]:
	var AABB_lower: Vector3 = position
	var AABB_upper: Vector3 = AABB_lower + Vector3(dimensions)
	
	var final_voxels: Dictionary[Vector3i, VoxelData]
	
	for pos in voxels:
		if !CollisionSystem.is_within_AABB(pos, AABB_lower, AABB_upper):
			continue
		
		if voxels[pos] != null and voxel_grid.has(pos):
			if voxels[pos].face_colors == voxel_grid[pos].face_colors:
				continue
		
		final_voxels[pos] = voxels[pos]
	
	return final_voxels

func change_voxels(voxels: Dictionary[Vector3i, VoxelData]) -> void:
	for pos in voxels:			
		if voxels[pos] == null and voxel_grid.has(pos):
			voxel_grid.erase(pos)
		
		var mesh_chunk = mesh_system.get_chunk_pos(pos, visual_offset)
		if !edited_chunks.has(mesh_chunk):
			edited_chunks.append(mesh_chunk)
		
		if voxels[pos] != null:
			voxel_grid[pos] = voxels[pos]
	
func create_BB_outline() -> void:
	var mesh_data = mesh_system.create_box(Vector3.ZERO, dimensions)
	outline_object = mesh_system.create_mesh_instance(mesh_data)
	outline_material.set_shader_parameter("grid_color", UserPreferences.unselected_color)
	outline_material.set_shader_parameter("grid_size", dimensions)
	outline_material.set_shader_parameter("line_width", UserPreferences.outline_selection_width)
		
	outline_object.mesh.surface_set_material(0, outline_material)
	add_child(outline_object)

func on_size_change() -> void:
	## Needs to change the mesh offset
	
	create_BB_outline()
	
func toggle_selection(selected: bool) -> void:
	## Need to redo all effected edge chunk meshes
	
	if selected:
		outline_material.set_shader_parameter("grid_color", UserPreferences.selection_color)
	else:
		outline_material.set_shader_parameter("grid_color", UserPreferences.unselected_color)
	outline_object.mesh.surface_set_material(0, outline_material)

func toggle_outline(on: bool) -> void:
	if on:
		outline_object.show()
	else:
		outline_object.hide()
