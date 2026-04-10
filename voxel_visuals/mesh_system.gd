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
	## So there's a dict of color palettes (MATERIALS)
	## Then their Vector3PackedArrays of mesh vertice data
	## Then the UVs for each "color in the color palette" for the same vertices
	var mesh: MeshInstance3D
	
	var mesh_vertex_list: Dictionary[int, PackedVector3Array]
	var mesh_UV_list: Dictionary[int, PackedVector2Array]
	
	for x in range(AABB_lower.x, AABB_upper.x):
		for y in range(AABB_lower.y, AABB_upper.y):
			for z in range(AABB_lower.z, AABB_upper.z):
				var pos = Vector3i(x, y, z)
				
				if !voxel_grid.has(pos):
					continue
					
				var voxel: VoxelData = voxel_grid[pos]
				
				for n in voxel.face_colors.size():
					var face_color: VoxelColor = voxel.face_colors[n]
					if !mesh_vertex_list.has(face_color.palette_id):
						mesh_vertex_list[face_color.palette_id] = PackedVector3Array()
						mesh_UV_list[face_color.palette_id] = PackedVector2Array()
					
					mesh_vertex_list[face_color.palette_id].append_array(get_face_array(n))
					mesh_UV_list[face_color.palette_id].append_array([face_color.color_id, 0])
	
	var array_mesh = ArrayMesh.new()
	var mesh_arrays: Array = [] 
	mesh_arrays.resize(Mesh.ARRAY_MAX)
			
	for surface in mesh_vertex_list:
		mesh_arrays[Mesh.ARRAY_VERTEX] = mesh_vertex_list[surface]
		mesh_arrays[Mesh.ARRAY_TEX_UV] = mesh_UV_list[surface]
		
		array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, mesh_arrays)
		
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = array_mesh
	
	print("SURFACE COUNT: ", array_mesh.get_surface_count())
		
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

func get_face_array(face_num: int) -> PackedVector3Array:
	assert(face_num >= 0 and face_num < 8, " face " + str(face_num) + " is out of bounds")
	return PackedVector3Array([
		cube_vertices[face_num], cube_vertices[face_num + 1], cube_vertices[face_num + 2], 
		cube_vertices[face_num + 3], cube_vertices[face_num + 4], cube_vertices[face_num + 5]])
		

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
