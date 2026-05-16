extends BaseBrush
class_name PointBrush

@export var size: float = 5.2
@export var requires_end: bool = true

func get_voxels(origin: Vector3, direction: Vector3, object: VoxelObject) -> Dictionary[Vector3i, VoxelData]:
	var voxels: Dictionary[Vector3i, VoxelData] = {}
	var positions: Array[Vector3i] = []
	var col_pos = get_collision_point(origin, direction, object)
	
	if col_pos.is_empty():
		return voxels
	
	positions.append_array(ShapeGeneration.create_sphere(col_pos[0], size))
	var AABB_lower = Vector3i(object.position)
	var AABB_upper = AABB_lower + object.dimensions
	positions = CollisionSystem.get_within_AABB(positions, AABB_lower, AABB_upper)
	
	var col: PaletteColor = get_selected_colors()[0]
	for pos in positions:
		voxels[pos] = get_monochrome_voxel(VoxelData.new(), col.color_id, col.palette_id)
	return voxels

func get_collision_point(origin: Vector3, direction: Vector3, object: VoxelObject) -> Array[Vector3i]:
	var voxel_cols: Array[Vector3i] = get_self_voxel_collision(origin, direction, object)
	if !voxel_cols.is_empty():
		return [voxel_cols[0]]
	
	var border_cols = get_first_border_collision(origin, direction, object)
	if !border_cols.is_empty():
		return [border_cols[0]]
		
	return []
