extends BaseBrush
class_name RailgunBrush

## Genuinely stupid name but it reminds me of a railgun!!

@export var size: float = 1.0

func get_voxels(origin: Vector3, direction: Vector3, object: VoxelObject) -> Dictionary[Vector3i, VoxelData]:
	var voxels: Dictionary[Vector3i, VoxelData]
	return voxels
	
func get_straight_collision(origin: Vector3, direction: Vector3, object: VoxelObject):
	return CollisionSystem.get_grid_traversal_collisions(origin, direction, object.voxel_grid, 32.0, false, 0)
