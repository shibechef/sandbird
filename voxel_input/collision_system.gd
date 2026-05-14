extends Node
class_name CollisionSystem

var obj_hierarchy: Hierarchy
var project_prefs: ProjectPreferences

func _ready():
	obj_hierarchy = get_node("%Hierarchy")
	project_prefs = get_node("%ProjectPreferences")

## 3D slab technique but by someone that forgot how to do algebra
static func get_AABB_line_collisions(origin: Vector3, direction: Vector3, targets: Dictionary[int, Array]) -> Array[Dictionary]:
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
		var AABB_lower: Vector3 = targets[target][0]
		var AABB_upper: Vector3 = targets[target][0] + Vector3(targets[target][1])
		
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
		
		## Don't hit things behind you as lines travel both ways
		for i in range(cols.size() - 1, -1, -1):
			if (origin - cols[i]).normalized().dot(direction.normalized()) > 0.0:
				cols.remove_at(i)

		## You can hit it once, if you are inside of the box
		assert(cols.size() <= 2, "magically hit AABB " + str(cols.size()) + " times")
		 
		if cols.size() == 0:
			continue
		
		var dist_1: float = origin.distance_to(cols[0])
		if cols.size() == 1:
			collisions.append({"id" = target, "col_1" = cols[0], "distance_1" = dist_1})
			continue
			
		var dist_2: float = origin.distance_to(cols[1])
		
		if dist_1 < dist_2:
			collisions.append({"id" = target, "col_1" = cols[0], "col_2" = cols[1], "distance_1" = dist_1, "distance_2" = dist_2})
		else:
			collisions.append({"id" = target, "col_1" = cols[1], "col_2" = cols[0], "distance_1" = dist_2, "distance_2" = dist_1})
	
	return collisions

## Do not use this for anything but voxel objects of course O_O
func get_first_outline_col(collisions: Array[Dictionary]) -> int:
	var margin: float = max(UserPreferences.outline_selection_width * 1.1, 1.0)
	var closest_collision: float = 10000.0
	var best_obj: int
	for collision in collisions:
		var object: VoxelObject = obj_hierarchy.all_objects[collision["id"]]
		var AABB_lower = object.position
		var AABB_upper = object.position + Vector3(object.dimensions)
		
		var cols = [collision["col_1"]]
		if collision.has("col_2"):
			cols.append(collision["col_2"])
			
		for i in cols.size():
			var col = cols[i]
			var near: int = 0
			near += int(AABB_lower.x > col.x - margin or col.x + margin > AABB_upper.x)
			near += int(AABB_lower.y > col.y - margin or col.y + margin > AABB_upper.y)
			near += int(AABB_lower.z > col.z - margin or col.z + margin > AABB_upper.z)
			
			## Needs to be near 2 axises to be a corner
			if near < 2:
				continue
			
			var dist: float
			if i == 0:
				dist = collision["distance_1"]
			else:
				dist = collision["distance_2"]
				
			if closest_collision < dist:
				continue
				
			closest_collision = dist
			best_obj = collision["id"]
			
	return best_obj

## https://web.archive.org/web/20121024081332/www.xnawiki.com/index.php?title=Voxel_traversal
static func get_grid_traversal_collisions(origin: Vector3, direction: Vector3, grid: Dictionary[Vector3i, VoxelData], distance: float, previous: bool = true, col_max: int = 1) -> Array[Vector3i]:
	var step: Vector3i = sign(direction)
	direction = direction.normalized()
	
	origin += Vector3(0.0, 0.0, 0.0)
	var max: Vector3 = Vector3(
		(1.0 if step.x == 1 else 0.0) / direction.x,
		(1.0 if step.y == 1 else 0.0) / direction.y,
		(1.0 if step.z == 1 else 0.0) / direction.z)
	if is_nan(max.x): max.x = INF
	if is_nan(max.y): max.y = INF
	if is_nan(max.z): max.z = INF
	max = abs(max)
		
	var delta: Vector3 = Vector3(
		float(step.x) / direction.x,
		float(step.y) / direction.y,
		float(step.z) / direction.z)
	if is_nan(delta.x): delta.x = INF
	if is_nan(delta.y): delta.y = INF
	if is_nan(delta.z): delta.z = INF
	
	var goal: Vector3 = abs(Vector3(origin + delta * distance))
	
	var current_pos: Vector3i = origin
	var last_pos: Vector3i
	
	var cols: Array[Vector3i]
		
	while cols.size() < col_max or col_max == 0:
		last_pos = current_pos
		if max.x < max.y and max.x < max.z:
			current_pos.x += step.x
			max.x += delta.x
			if abs(current_pos.x) > goal.x:
				break
		elif max.y < max.z:
			current_pos.y += step.y
			max.y += delta.y
			if abs(current_pos.y) > goal.y:
				break
		else:
			current_pos.z += step.z
			max.z += delta.z
			if abs(current_pos.z) > goal.z:
				break
		
		if grid.has(current_pos) or col_max == 0:
			if previous:
				cols.append(last_pos)
			else:
				cols.append(current_pos)
				
	return cols

static func is_within_AABB(point: Vector3i, AABB_lower: Vector3i, AABB_higher: Vector3i) -> bool:
	if (AABB_lower.x > point.x or point.x > AABB_higher.x or
	 AABB_lower.y > point.y or point.y > AABB_higher.y or
	 AABB_lower.z > point.z or point.z > AABB_higher.z):
		return false
	return true
