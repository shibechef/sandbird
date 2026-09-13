extends Node

var current_project: VoxelProject

func save_project(file_path: String) -> void:
	var save_state := SaveState.new()
	
	var objs: Dictionary[int, VoxelObject] = current_project.get_node("%Hierarchy").all_objects
	for key in objs:
		var obj: VoxelObject = objs[key]
		print(obj.dimensions)
		var voxel_obj_data := VoxelObjectData.new()
		voxel_obj_data.voxel_grid = obj.voxel_grid
		voxel_obj_data.dimensions = obj.dimensions
		voxel_obj_data.position = obj.global_position
		save_state.objects.append(voxel_obj_data)
	
	save_state.brushes = current_project.get_node("%PaintSystem").brush_list
	
	var palette_manager: ColorPaletteManager = current_project.get_node("%ColorPaletteManager")
	save_state.palettes = palette_manager.all_palettes
	save_state.palette_order = palette_manager.palettes_by_order
		
	ResourceSaver.save(save_state, file_path)

func load_project() -> void:
	return
