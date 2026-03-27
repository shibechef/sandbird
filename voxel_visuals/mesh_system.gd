extends Node
class_name MeshSystem

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

func create_voxel(origin: Vector3i, starting_index: int) -> Array:
	var indices: PackedInt32Array
	var vertices: PackedVector3Array

	for vert in offsets:
		vertices.append(vert + Vector3(origin))
	
	## Y- face
	indices.append_array(create_square(0, 1, 3, 2))
	## Y+ face
	indices.append_array(create_square(4, 6, 7, 5))
	## Z- face
	indices.append_array(create_square(1, 0, 4, 5))
	## Z+ face
	indices.append_array(create_square(2, 3, 7, 5))
	## X- face
	indices.append_array(create_square(0, 2, 6, 4))
	## X+ face
	indices.append_array(create_square(3, 1, 5, 7))
	return [indices, vertices]

## Bottom left, bottom right, top right, top left
func create_square(vert_SW: int, vert_SE: int, vert_NE: int, vert_NW: int) -> PackedInt32Array:
	return PackedInt32Array([vert_SW, vert_SE, vert_NE, vert_NE, vert_NW, vert_SW])
