extends Node

var empty_scene: PackedScene = preload("res://scenes/blank_voxel_project.tscn")

var current_project: VoxelProject

func save_project(file_path: String) -> void:
	var save_state := SaveState.new()
	
	var objs: Dictionary[int, VoxelObject] = current_project.get_node("%Hierarchy").all_objects
	for key in objs:
		var obj: VoxelObject = objs[key]
		var voxel_obj_data := VoxelObjectData.new()
		voxel_obj_data.voxel_grid = obj.voxel_grid.duplicate_deep(true)
		voxel_obj_data.dimensions = obj.dimensions
		voxel_obj_data.position = obj.global_position
		save_state.objects.append(voxel_obj_data)
	
	save_state.save_time = Time.get_datetime_dict_from_system()
	
	save_state.brushes = current_project.get_node("%PaintSystem").brush_list.duplicate(true)
	
	var palette_manager: ColorPaletteManager = current_project.get_node("%ColorPaletteManager")
	save_state.palettes = palette_manager.all_palettes.duplicate(true)
	save_state.palette_order = palette_manager.palettes_by_order.duplicate()
	
	var error: int = ResourceSaver.save(save_state, file_path)
	assert(error == 0, error_string(error))

func load_project(save_state: SaveState) -> void:
	var project: VoxelProject = empty_scene.instantiate()
	var hierarchy: Hierarchy = project.get_node("%Hierarchy")
	var paint_system: PaintSystem = project.get_node("%PaintSystem")
	var palette_manager: ColorPaletteManager = project.get_node("%ColorPaletteManager")
	
	for obj_data in save_state.objects:
		var voxel_obj := VoxelObject.new()
		hierarchy.add_object(voxel_obj, false)
		voxel_obj.dimensions = obj_data.dimensions
		voxel_obj.position = obj_data.position
		voxel_obj.call_deferred("change_voxels", obj_data.voxel_grid.duplicate())
	
	paint_system.add_brushes(save_state.brushes.values())
	palette_manager.add_palettes(save_state.palettes, save_state.palette_order)
	
	var program = get_tree().current_scene
	if program.has_node("VoxelProject"):
		program.get_node("VoxelProject").name = "stupid"
		program.get_node("stupid").queue_free()
	program.add_child(project)
	project.name = "VoxelProject"
