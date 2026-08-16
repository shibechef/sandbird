extends BaseBrush
class_name BeamBrush

@export var size: float = 1.0

func get_voxels(input_data: Dictionary, object: VoxelObject, cols: Array[PaletteColor]) -> Dictionary[Vector3i, VoxelData]:
	var voxels: Dictionary[Vector3i, VoxelData]
	var rays = get_interpolated_rays(input_data["origin_0"], input_data["dir_0"], input_data["origin_1"], input_data["dir_1"])
	for ray in rays:
		var positions = get_straight_collision(ray[0], ray[1], object)
		for pos in positions:
			if voxels.has(pos):
				continue
			
			voxels[pos] = get_monochrome_voxel(VoxelData.new(), cols[0].color_id, cols[0].palette_id)
	return voxels

func get_straight_collision(origin: Vector3, direction: Vector3, object: VoxelObject) -> Array[Vector3i]:
	return CollisionSystem.get_grid_traversal_collisions(origin, direction, object.voxel_grid, depth, false, 0)
