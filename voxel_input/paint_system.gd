extends Node
class_name PaintSystem

var object_selection: ObjectSelectionSystem
var collision_system: CollisionSystem
var palette_manager: ColorPaletteManager
var mesh_system: MeshSystem

func _ready():
	object_selection = get_node("%ObjectSelectionSystem")
	collision_system = get_node("%CollisionSystem")
	palette_manager = get_node("%ColorPaletteManager")
	mesh_system = get_node("%MeshSystem")

func try_click() -> void:
	var position: Vector3 = get_collision_pos()
	var tiles = get_adjusted_tiles(position)
	paint_tiles(tiles)

func paint_tiles(tiles: Array[Vector3i]) -> void:
	var object_importance_order: Array[VoxelObject]
	var object_importance_dict: Dictionary[VoxelObject, int]
	for id in object_selection.currently_selected_objects:
		var obj = object_selection.currently_selected_objects[id]
		if id == object_selection.highest_priority_selection:
			object_importance_dict[obj] = 0
		else:
			object_importance_dict[obj] = object_selection.currently_selected_objects[id].dimensions.length_squared()
	
	object_importance_dict.sort()
	object_importance_order = object_importance_dict.keys()
	
	for tile in tiles:
		## check if this tile is in the highest priority grid, otherwise do the smallest grid -> biggest grid that it's in
		for selected_obj in object_importance_order:
			var pos = Vector3i(selected_obj.position)
			if collision_system.is_within_AABB(tile, pos, pos + selected_obj.dimensions):
				var local_space = tile - pos
				paint_tile(local_space, selected_obj)
			

func paint_tile(tile: Vector3i, object: VoxelObject) -> void:
	var voxel_data: VoxelData = VoxelData.new()
	for face in voxel_data.face_colors:
		face.color_id = palette_manager.get_current_color()
		face.palette_id = palette_manager.palette_by_color[face.color_id]
	object.voxel_grid[tile] = voxel_data
	
	print(tile)
	
	## for now!
	var meshes = mesh_system.generate_chunk_meshes(object.dimensions, object.voxel_grid)
	for chunk_pos: Vector3i in meshes:
		var mesh: MeshInstance3D = meshes[chunk_pos]
		object.add_child(mesh)


func get_adjusted_tiles(paint_position: Vector3i) -> Array[Vector3i]:
	## For now!
	return [paint_position]

func get_collision_pos() -> Vector3i:
	var closest_collision: Vector3i
	
	var click_data = get_parent().get_node("%WorldClick").get_mouse_world_pos()
	var result: Array[Dictionary]
	var objs: Dictionary[int, Array]
	for obj in object_selection.currently_selected_objects:
		objs[obj] = [object_selection.currently_selected_objects[obj].position, object_selection.currently_selected_objects[obj].dimensions]
	
	result = collision_system.get_AABB_line_collisions(click_data[0], click_data[1], objs)
	
	## Do voxel looking first
	
	
	
	## Bounding box collision if nothing is before it
	var furthest_distance: float = -1.0
	var furthest_point: Vector3
	
	for dict in result:
		if dict.has("distance_2"):
			if dict["distance_2"] > furthest_distance:
				furthest_distance = dict["distance_2"]
				furthest_point = dict["col_2"]
		else:
			if dict["distance_1"] > furthest_distance:
				furthest_distance = dict["distance_1"]
				furthest_point = dict["col_1"]
	
	closest_collision = furthest_point
	
	return closest_collision
	
