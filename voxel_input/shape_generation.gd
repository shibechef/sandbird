extends Node
class_name ShapeGeneration

static func create_sphere(origin: Vector3i, radius: float) -> Array[Vector3i]:
	var voxels: Array[Vector3i]
	var radius_squared: float = radius * radius
	
	var end: int = ceili(radius)
	for x in range(0, end + 1):
		var x_adj: float = x
		var x_squared: float = x_adj * x_adj
		for y in range(0, end + 1):
			var y_adj: float = y
			var y_squared: float = y_adj * y_adj
			for z in range(0, end + 1):
				var z_adj: float = z
				var z_squared: float = z_adj * z_adj
				if x_squared + y_squared + z_squared <= radius_squared:
					voxels.append_array([
						origin + Vector3i(x, -y, -z),
						origin + Vector3i(x, y, -z),
						origin + Vector3i(x, -y, z),
						origin + Vector3i(x, y, z),
						origin + Vector3i(-x, -y, z),
						origin + Vector3i(-x, y, z),
						origin + Vector3i(-x, -y, -z),
						origin + Vector3i(-x, y, -z)
					])

	return voxels
