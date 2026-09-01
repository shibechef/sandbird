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
var palette_manager: ColorPaletteManager
var cascade_solver: RadianceCascadeSolver

var empty_col: Color = Color(0.0, 0.0, 0.0, 0.0)

var time: float = 0.0

func on_created() -> void:
	dimensions = project_prefs.default_object_size

func _process(delta):
	update_mesh_chunks()
	time += delta
	if time > 1.0:
		time -= 1.0

func _ready():		
	mutex = Mutex.new()
	mesh_system = get_parent().get_node("%MeshSystem")
	project_prefs = get_parent().get_node("%ProjectPreferences")
	collision_system = get_parent().get_node("%CollisionSystem")
	palette_manager = get_parent().get_node("%ColorPaletteManager")
	cascade_solver = get_parent().get_node("%RadianceCascadeSolver")
	
	outline_material = outline_material.duplicate()
	
	if dimensions == Vector3i.ZERO:
		dimensions = project_prefs.default_object_size
	
	create_BB_outline()

func update_mesh_chunks() -> void:
	if edited_chunks.size() == 0:
		return
	
	var id = WorkerThreadPool.add_group_task(update_chunk_visual, edited_chunks.size())
	WorkerThreadPool.wait_for_group_task_completion(id)
	edited_chunks.clear()
	
	cascade_solver.compute_radiance_texture(1)
	#var texture_array: Texture2DArray = get_texture_array()
	#cascade_debug.set_shader_parameter("voxels", texture_array)

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

## 6^3, 24^3, 96^3, 150^3, 216^3, etc are the only square texture sizes
#func get_texture_array(size: int = 96) -> Texture2DArray:
	#var text_size: float = sqrt(float(size * size * size * 6))
	#assert(text_size - floor(text_size) < .00001 and ceil(text_size) - text_size < .00001, " chunk size of " + String.num(size) + " is not a sufficient size.")
	#
	#var texture_array := Texture2DArray.new()
	#var all_images: Array[Image] = []
	#var size_x = ceili(float(dimensions.x) / float(size))
	#var size_y = ceili(float(dimensions.y) / float(size))
	#var size_z = ceili(float(dimensions.z) / float(size))
	#for x in size_x:
		#for y in size_y:
			#for z in size_z:
				#var chunk: Vector3i = Vector3i(x, y, z)
				#all_images.append(get_voxel_texture(chunk, size, int(text_size)))
#
	#texture_array.create_from_images(all_images)
	#
	#return texture_array

#func get_voxel_texture(current_chunk: Vector3i, size: int, text_size: int) -> Image:
	#var image := Image.create(text_size, text_size, false, Image.FORMAT_RGBA16)
	#var offset: Vector3i = current_chunk * size
	#var current_x: int = 0
	#var current_y: int = 0
	#for x in size:
		#for y in size:
			#for z in size:
				### probably cheaper than finding these with math
				#if current_x == text_size:
					#current_x = 0
					#current_y += 1
				#var pos: Vector3i = Vector3i(x, y, z) + offset
				#
				#if !voxel_grid.has(pos):
					#for i in 6:
						#image.set_pixel(current_x + i, current_y, empty_col)
					#current_x += 6
					#continue	
				#
				#var voxel: VoxelData = voxel_grid[pos]
				#if voxel.face_colors.size() == 1:
					#var col: Color = palette_manager.get_color_from_id(voxel.face_colors[0]).color
					#for i in 6:
						#image.set_pixel(current_x + i, current_y, col)
				#else:
					#for i in 6:
						#image.set_pixel(current_x + i, current_y, palette_manager.get_color_from_id(voxel.face_colors[i]).color)
				#current_x += 6
	#return image

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
