extends BaseBrush
class_name PointBrush

@export var size: float = 5.2
@export var requires_end: bool = true
@export var shaved: bool = true
@export var erase: bool = false

func get_voxels(input_data: Dictionary, object: VoxelObject, cols: Array[PaletteColor]) -> Dictionary[Vector3i, VoxelData]:
	var voxels: Dictionary[Vector3i, VoxelData] = {}
	var positions: Array[Vector3i] = []
	var effective_size: float = size * 0.9999 if shaved else 1.0
	
	var rays = get_interpolated_rays(input_data["origin_0"], input_data["dir_0"], input_data["origin_1"], input_data["dir_1"], .75, 1.0)
	for ray in rays:
		var col_pos = get_collision_point(ray[0], ray[1], object)
		
		if col_pos.is_empty():
			continue
		
		positions.append_array(ShapeGeneration.create_sphere(col_pos[0], effective_size))
		var AABB_lower = Vector3i(object.position)
		var AABB_upper = AABB_lower + object.dimensions
		positions = CollisionSystem.get_within_AABB(positions, AABB_lower, AABB_upper)
	
		for pos in positions:
			if !voxels.has(pos):
				if erase:
					voxels[pos] = null
				else:
					voxels[pos] = get_monochrome_voxel(VoxelData.new(), cols[0].color_id, cols[0].palette_id)
	return voxels

func get_collision_point(origin: Vector3, direction: Vector3, object: VoxelObject) -> Array[Vector3i]:
	var voxel_cols: Array[Vector3i] = get_self_voxel_collision(origin, direction, object)
	if !voxel_cols.is_empty():
		return [voxel_cols[0]]
	
	var border_cols = get_first_border_collision(origin, direction, object)
	if !border_cols.is_empty():
		return [border_cols[0]]
		
	return []
