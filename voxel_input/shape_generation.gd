extends Node
class_name ShapeGeneration

static func create_sphere(origin: Vector3i, radius: float) -> Array[Vector3i]:
	var voxels: Array[Vector3i]
	var radius_squared: float = radius * radius
	
	var start = -radius
	var end = radius
	for x in range(start, end):
		var x_adj = x + .5
		var x_squared = x_adj * x_adj
		for y in range(start, end):
			var y_adj = y + .5
			var y_squared = y_adj * y_adj
			for z in range(start, end):
				var z_adj = z + .5
				var z_squared = z_adj * z_adj
				var pos = Vector3i(x, y, z)
				if x_squared + y_squared + z_squared <= radius_squared:
					voxels.append(pos + origin)

	return voxels
