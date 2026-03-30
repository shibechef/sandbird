extends Node
class_name CollisionSystem

func _ready():
	return
	#var john_obj4 = [Vector3(5.0, 0.0, 0.0), Vector3(1.0, 1.0, 1.0)]
	#var results4 = get_AABB_line_collisions(Vector3.ZERO, Vector3(1.0, 0.02, -0.01), {0: john_obj4})
	#
	#var john_obj = [Vector3(8.0, 4.0, 8.0), Vector3(2.0, 2.0, 2.0)]
	#var results = get_AABB_line_collisions(Vector3.ZERO, Vector3(1.00, 0.505, 1.1), {0: john_obj})
#
	#var john_obj2 = [Vector3(8.0, 8.0, 8.0), Vector3(1.0, 1.0, 1.0)]
	#var results2 = get_AABB_line_collisions(Vector3.ZERO, Vector3(1.0, .99, 1.02), {0: john_obj2})
	#
	###THIS IS SUCCESSFUL
	#var john_obj3 = [Vector3(0.0, 8.0, 0.0), Vector3(1.0, 1.0, 1.0)]
	#var results3 = get_AABB_line_collisions(Vector3.ZERO, Vector3(.05, 1.01, .01), {0: john_obj3})


## 3D slab technique but by someone that forgot how to do algebra
func get_AABB_line_collisions(origin: Vector3, direction: Vector3, targets: Dictionary[int, Array]) -> Array[Dictionary]:
	var collisions: Array[Dictionary]

	var x_slope: float
	var z_slope: float
	
	if direction.x == 0.0:
		x_slope = 0.0
	else:
		x_slope = direction.y / direction.x
	if direction.z == 0.0:
		z_slope = 0.0
	else:
		z_slope = direction.y / direction.z
			
	for target in targets:		
		var AABB_lower: Vector3 = targets[target][0] - targets[target][1] / 2.0
		var AABB_upper: Vector3 = targets[target][0] + targets[target][1] / 2.0
		
		## Where the y/x and y/z components of the line hit
		## the x line hits the z axis, the z line hits the x axis
		## https://www.youtube.com/shorts/GqwUHXvQ7oA is a good 2D visualization
		
		## y+ plane hits
		var pos_y_z: float = (AABB_upper.y - origin.y) / z_slope + origin.z
		var pos_y_x: float = (AABB_upper.y - origin.y) / x_slope + origin.x
		## y- plane hits
		var neg_y_z: float = (AABB_lower.y - origin.y) / z_slope + origin.z
		var neg_y_x: float = (AABB_lower.y - origin.y) / x_slope + origin.x
		## z+ plane hits
		var pos_z_y: float = origin.y + z_slope * (AABB_upper.z - origin.z)
		var pos_z_x: float = origin.x + (AABB_upper.z - origin.z) * z_slope / x_slope
		## z- plane hits
		var neg_z_y: float = origin.y + z_slope * (AABB_lower.z - origin.z)
		var neg_z_x: float = origin.x + (AABB_lower.z - origin.z) * z_slope / x_slope
		## x+ plane hits
		var pos_x_y: float = origin.y + x_slope * (AABB_upper.x - origin.x)
		var pos_x_z: float = origin.z + (AABB_upper.x - origin.x) * x_slope / z_slope
		## x- plane hits
		var neg_x_y: float = origin.y + x_slope * (AABB_lower.x - origin.x)
		var neg_x_z: float = origin.z + (AABB_lower.x - origin.x) * x_slope / z_slope
		
		var cols: Array[Vector3]
		(AABB_lower.z < neg_y_z and neg_y_z < AABB_upper.z) and (AABB_lower.x < neg_y_x and neg_y_x < AABB_upper.x),
		(AABB_lower.y < pos_z_y and pos_z_y < AABB_upper.y) and (AABB_lower.x < pos_z_x and pos_z_x < AABB_upper.x),
		(AABB_lower.y < neg_z_y and neg_z_y < AABB_upper.y) and (AABB_lower.x < neg_z_x and neg_z_x < AABB_upper.x),
		(AABB_lower.y < pos_x_y and pos_x_y < AABB_upper.y) and (AABB_lower.z < pos_x_z and pos_x_z < AABB_upper.z),
		(AABB_lower.y < neg_x_y and neg_x_y < AABB_upper.y) and (AABB_lower.z < neg_x_z and neg_x_z < AABB_upper.z))
		## Y+
		if (AABB_lower.z < pos_y_z and pos_y_z < AABB_upper.z) and (AABB_lower.x < pos_y_x and pos_y_x < AABB_upper.x):
			cols.append(Vector3(pos_y_x, AABB_upper.y, pos_y_z))
		## Y-
		if (AABB_lower.z < neg_y_z and neg_y_z < AABB_upper.z) and (AABB_lower.x < neg_y_x and neg_y_x < AABB_upper.x):
			cols.append(Vector3(neg_y_x, AABB_lower.y, neg_y_z))
		## Z+
		if (AABB_lower.y < pos_z_y and pos_z_y < AABB_upper.y) and (AABB_lower.x < pos_z_x and pos_z_x < AABB_upper.x):
			cols.append(Vector3(pos_z_x, pos_z_y, AABB_upper.z))
		## Z-
		if (AABB_lower.y < neg_z_y and neg_z_y < AABB_upper.y) and (AABB_lower.x < neg_z_x and neg_z_x < AABB_upper.x):
			cols.append(Vector3(neg_z_x, neg_z_y, AABB_lower.z))
		## X+
		if (AABB_lower.y < pos_x_y and pos_x_y < AABB_upper.y) and (AABB_lower.z < pos_x_z and pos_x_z < AABB_upper.z):
			cols.append(Vector3(AABB_upper.x, pos_x_y, pos_x_z))
		## X-
		if (AABB_lower.y < neg_x_y and neg_x_y < AABB_upper.y) and (AABB_lower.z < neg_x_z and neg_x_z < AABB_upper.z):
			cols.append(Vector3(AABB_lower.x, neg_x_y, neg_x_z))

		## You can hit it once, if you are inside of the box
		assert(cols.size() <= 2, "magically hit AABB " + str(cols.size()) + " times")
		
		if cols.size() == 0:
			continue
		
		collisions.append({"id" = 0, "col_1" = cols[0], "col_2" = cols[1], "distance" = 2.0})
	
	return collisions
