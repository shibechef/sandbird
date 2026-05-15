extends Node
class_name ShapeGeneration

static func create_sphere(origin: Vector3i, radius: float) -> Array[Vector3i]:
	var voxels: Array[Vector3i]
	var radius_squared: float = radius * radius
	
	for x in range(-radius, radius):
		var x_squared = x * x
		for y in range(-radius, radius):
			var y_squared = y * y
			for z in range(-radius, radius):
				var z_squared = z * z
				var pos = Vector3i(x, y, z)
				if x_squared + y_squared + z_squared <= radius_squared:
					voxels.append(pos + origin)

	return voxels
