extends Node
class_name MeshSystem

var project_prefs: ProjectPreferences
var color_palette_manager: ColorPaletteManager

var cube_vertices: PackedVector3Array = [
	## Y- face
	Vector3(0, 0, 0), Vector3(1, 0, 0), Vector3(1, 0, 1), Vector3(1, 0, 1), Vector3(0, 0, 1), Vector3(0, 0, 0),
	## Y+ face
	Vector3(0, 1, 0), Vector3(0, 1, 1), Vector3(1, 1, 1), Vector3(1, 1, 1), Vector3(1, 1, 0), Vector3(0, 1, 0),
	## Z- face
	Vector3(1, 0, 0), Vector3(0, 0, 0), Vector3(0, 1, 0), Vector3(0, 1, 0), Vector3(1, 1, 0), Vector3(1, 0, 0),
	## Z+ face
	Vector3(0, 0, 1), Vector3(1, 0, 1), Vector3(1, 1, 1), Vector3(1, 1, 1), Vector3(0, 1, 1), Vector3(0, 0, 1),
	## X- face
	Vector3(0, 0, 0), Vector3(0, 0, 1), Vector3(0, 1, 1), Vector3(0, 1, 1), Vector3(0, 1, 0), Vector3(0, 0, 0),
	## X+ face
	Vector3(1, 0, 1), Vector3(1, 0, 0), Vector3(1, 1, 0), Vector3(1, 1, 0), Vector3(1, 1, 1), Vector3(1, 0, 1)
]

func _ready():
	project_prefs = get_node("%ProjectPreferences")
	color_palette_manager = get_node("%ColorPaletteManager")

func generate_chunk_meshes(dimensions: Vector3i, voxel_grid: Dictionary[Vector3i, VoxelData]) -> Dictionary[Vector3i, MeshInstance3D]:
	var chunks: Dictionary[Vector3i, MeshInstance3D]
	
	var chunk_size = project_prefs.mesh_chunk_size
		
	for x_chunk in ceili(float(dimensions.x) / float(chunk_size)):
		for y_chunk in ceili(float(dimensions.y) / float(chunk_size)):
			for z_chunk in ceili(float(dimensions.z) / float(chunk_size)):
				var AABB_lower = Vector3i(x_chunk, y_chunk, z_chunk) * chunk_size
				var AABB_upper = AABB_lower + Vector3i.ONE * chunk_size
				chunks[Vector3i(x_chunk, y_chunk, z_chunk)] = get_chunk_mesh(AABB_lower, AABB_upper, voxel_grid)
		
	return chunks

func get_chunk_mesh(AABB_lower: Vector3i, AABB_upper: Vector3i, voxel_grid: Dictionary[Vector3i, VoxelData], offset: Vector3i = Vector3i.ZERO) -> MeshInstance3D:
	return
	
	var array_mesh = ArrayMesh.new()
	var mesh_arrays: Array = [] 
	var material_count: int = 0
	mesh_arrays.resize(Mesh.ARRAY_MAX)
	
	#var material_dict = Dictionary[]

	#mesh_arrays[Mesh.ARRAY_VERTEX] = vertices
	#mesh_arrays[Mesh.ARRAY_INDEX] = indices
	
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, mesh_arrays)
	
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = array_mesh
	
	return mesh_instance

## Slightly stripped down box cause this is called a lot
func create_voxel(origin: Vector3) -> PackedVector3Array:
	var vertices: PackedVector3Array

	for vert in cube_vertices:
		vertices.append(origin + vert)
	
	return vertices

func create_box(origin: Vector3, dimensions: Vector3) -> PackedVector3Array:
	var vertices: PackedVector3Array

	for vert in cube_vertices:
		vertices.append(origin + Vector3(vert.x * dimensions.x, vert.y * dimensions.y, vert.z * dimensions.z))
	
	return vertices

## Bottom left, bottom right, top right, top left
func create_square(vert_SW: Vector3, vert_SE: Vector3, vert_NE: Vector3, vert_NW: Vector3) -> PackedVector3Array:
	return PackedVector3Array([vert_SW, vert_SE, vert_NE, vert_NE, vert_NW, vert_SW])

func create_mesh_instance(vertices: PackedVector3Array, UVs: PackedVector2Array = []) -> MeshInstance3D:
	var array_mesh = ArrayMesh.new()
	var mesh_arrays: Array = [] 
	mesh_arrays.resize(Mesh.ARRAY_MAX)

	mesh_arrays[Mesh.ARRAY_VERTEX] = vertices
	if !UVs.is_empty():
		mesh_arrays[Mesh.ARRAY_TEX_UV] = UVs
	
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, mesh_arrays)
	
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = array_mesh
	
	return mesh_instance
