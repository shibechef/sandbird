extends Resource
class_name BaseBrush

@export var named_as: String
@export var depth: float = 100.0

func get_voxels(origin: Vector3, direction: Vector3, object: VoxelObject) -> Dictionary[Vector3i, VoxelData]:
	var voxels: Dictionary[Vector3i, VoxelData]
	assert(false, "brush " + resource_name + " using default logic!!")
	
	return voxels

func get_self_voxel_collision(origin: Vector3, direction: Vector3, object: VoxelObject) -> Array[Vector3i]:
	var cols = CollisionSystem.get_grid_traversal_collisions(origin, direction, object.voxel_grid, depth)
	
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
		
func get_monochrome_voxel(voxel: VoxelData, color: VoxelColor) -> VoxelData:
	for face in voxel.face_colors:
		face.color_id = color.color_id
		face.palette_id = color.palette_id
	
	return voxel

func get_selected_colors() -> Array[VoxelColor]:
	var colors: Array[VoxelColor]
	var manager: ColorPaletteManager = ProjectManager.current_project.get_node("%ColorPaletteManager")
	for color in manager.currently_selected_colors:
		var voxel_color = VoxelColor.new()
		voxel_color.color_id = color
		voxel_color.palette_id = manager.palette_by_color[color]
		colors.append(voxel_color)
	return colors
