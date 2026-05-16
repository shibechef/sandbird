extends BaseBrush
class_name BeamBrush

@export var size: float = 1.0

func get_voxels(origin: Vector3, direction: Vector3, object: VoxelObject) -> Dictionary[Vector3i, VoxelData]:
	var voxels: Dictionary[Vector3i, VoxelData]
	var positions = get_straight_collision(origin, direction, object)
	var col: PaletteColor = get_selected_colors()[0]
	for pos in positions:
		voxels[pos] = get_monochrome_voxel(VoxelData.new(), col.color_id, col.palette_id)
	return voxels
	
func get_straight_collision(origin: Vector3, direction: Vector3, object: VoxelObject) -> Array[Vector3i]:
	return CollisionSystem.get_grid_traversal_collisions(origin, direction, object.voxel_grid, depth, false, 0)
