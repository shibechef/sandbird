extends Node
class_name PaintSystem

var object_selection: ObjectSelectionSystem
var collision_system: CollisionSystem
var palette_manager: ColorPaletteManager
var mesh_system: MeshSystem

var current_mode: PaintingMode = PaintingMode.rail

func _ready():
	object_selection = get_node("%ObjectSelectionSystem")
	collision_system = get_node("%CollisionSystem")
	palette_manager = get_node("%ColorPaletteManager")
	mesh_system = get_node("%MeshSystem")

func try_click() -> void:
	var tiles: Array[Vector3i]
	
	var click_data = get_parent().get_node("%WorldClick").get_mouse_world_pos()
	
	
	
	
	match current_mode:
		PaintingMode.basic:
			## Add more tiles for bigger size or whatever else
			tiles.append_array(get_first_collision())
		PaintingMode.rail:
			tiles.append_array(get_rail_collision())
			
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
			if !collision_system.is_within_AABB(tile, pos, pos + selected_obj.dimensions):
				continue
				
			var local_space = tile - pos
			selected_obj.add_voxels(tile)
			paint_tile(local_space, selected_obj)
			break

func get_paint_color(tile: Vector3i, object: VoxelObject) -> void:
	
	var voxel_data: VoxelData = VoxelData.new()
	for face in voxel_data.face_colors:
		face.color_id = palette_manager.get_current_color()
		face.palette_id = palette_manager.palette_by_color[face.color_id]
	object.voxel_grid[tile] = voxel_data
		
	## for now!
	var meshes = mesh_system.generate_chunk_meshes(object.dimensions, object.voxel_grid)
	for chunk_pos: Vector3i in meshes:
		var mesh: MeshInstance3D = meshes[chunk_pos]
		object.add_child(mesh)

enum PaintingMode{
	basic,
	rail
}
