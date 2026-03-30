extends Node
class_name MeshSystem

var project_prefs: ProjectPreferences

var offsets: Array[Vector3] = [
	Vector3(0, 0, 0),
	Vector3(1, 0, 0),
	Vector3(0, 0, 1),
	Vector3(1, 0, 1),
	Vector3(0, 1, 0),
	Vector3(1, 1, 0),
	Vector3(0, 1, 1),
	Vector3(1, 1, 1)
]

var cube_indices: PackedInt32Array = [
	## Y- face
	0, 1, 3, 3, 2, 0,
	## Y+ face
	4, 6, 7, 7, 5, 4,
	## Z- face
	1, 0, 4, 4, 5, 1,
	## Z+ face
	2, 3, 7, 7, 6, 2,
	## X- face
	0, 2, 6, 6, 4, 0,
	## X+ face
	3, 1, 5, 5, 7, 3
]

func _ready():
	project_prefs = get_node("%ProjectPreferences")

## Slightly stripped down box cause this is called a lot
func create_voxel(origin: Vector3, starting_index: int = 0) -> Array:
	var indices: PackedInt32Array = get_cube_indices(starting_index)
	var vertices: PackedVector3Array 

	for vert in offsets:
		vertices.append(origin + vert)
	
	return [indices, vertices]

func create_box(origin: Vector3, dimensions: Vector3, starting_index: int = 0) -> Array:
	var indices: PackedInt32Array = get_cube_indices(starting_index)
	var vertices: PackedVector3Array 
				
	for vert in offsets:
		vertices.append(origin + Vector3(vert.x * dimensions.x, vert.y * dimensions.y, vert.z * dimensions.z))
	
	return [indices, vertices]

func get_cube_indices(starting_index: int) -> PackedInt32Array:
	var indices: PackedInt32Array
	indices.append_array(cube_indices)
	
	if starting_index != 0:
		for index in indices:
			index += starting_index
	
	return indices

## Bottom left, bottom right, top right, top left
func create_square(vert_SW: int, vert_SE: int, vert_NE: int, vert_NW: int) -> PackedInt32Array:
	return PackedInt32Array([vert_SW, vert_SE, vert_NE, vert_NE, vert_NW, vert_SW])

func create_mesh_instance(indices: PackedInt32Array, vertices: PackedVector3Array) -> MeshInstance3D:
	var array_mesh = ArrayMesh.new()
	var mesh_arrays: Array = [] 
	mesh_arrays.resize(Mesh.ARRAY_MAX)

	mesh_arrays[Mesh.ARRAY_VERTEX] = vertices
	mesh_arrays[Mesh.ARRAY_INDEX] = indices
	
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, mesh_arrays)
	
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = array_mesh
	
	return mesh_instance
