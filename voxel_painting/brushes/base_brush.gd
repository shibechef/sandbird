extends Resource
class_name BaseBrush

@export var named_as: String
@export var depth: float = 300.0
@export var default_colors: Array[int]

func get_voxels(input_data: Dictionary, object: VoxelObject, cols: Array[PaletteColor]) -> Dictionary[Vector3i, VoxelData]:
	var voxels: Dictionary[Vector3i, VoxelData]
	return voxels
	
func get_self_voxel_collision(origin: Vector3, direction: Vector3, object: VoxelObject) -> Array[Vector3i]:
	var cols = CollisionSystem.get_grid_traversal_collisions(origin, direction, object.previous_grid, depth)
	return cols

func get_first_border_collision(origin: Vector3, direction: Vector3, object: VoxelObject) -> Array[Vector3i]:
	var AABB_lower: Vector3 = object.position
	var AABB_upper: Vector3 = AABB_lower + Vector3(object.dimensions)
	var result = CollisionSystem.get_AABB_line_collisions(origin, direction, {object.get_instance_id(): [AABB_lower, AABB_upper]})
	
	if result.is_empty():
		return []
		
	if result[0].has("distance_2"):
		return [Vector3i(result[0]["col_2"])]
	else:
		return [Vector3i(result[0]["col_1"])]
		
func get_monochrome_voxel(voxel: VoxelData, color_id: int, palette_id: int) -> VoxelData:
	voxel.face_colors = [color_id]
	voxel.face_palettes = [palette_id]
	
	return voxel

func get_interpolated_rays(origin_0: Vector3, dir_0: Vector3, origin_1: Vector3, dir_1: Vector3, distance_rate: float = 0.75, angle_rate: float = 0.3) -> Array[Array]:
	var ray_count: int = max(1, floori(origin_0.distance_to(origin_1) / distance_rate + rad_to_deg(dir_0.angle_to(dir_1)) / angle_rate))
	var rays: Array[Array]
	for n in ray_count:
		var progress := float(n) / float(ray_count)
		var basis_0 = Basis.from_euler(dir_0)
		var basis_1 = Basis.from_euler(dir_1)
		rays.append([lerp(origin_0, origin_1, progress), basis_0.slerp(basis_1, progress).get_euler()])
	return rays
