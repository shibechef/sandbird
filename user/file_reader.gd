extends Node

var brush_path: String = "res://user/brushes/"
var palette_path: String = "res://user/palettes/"

func get_folder_contents(file_path: String, type: String, recursive: bool = false) -> Array[String]:
	var dir = DirAccess.open(file_path)
	assert(dir != null, file_path + " does not exist!")
	dir.list_dir_begin()
	var file = dir.get_next()
	var contents: Array[String] = []
	while file != "":		
		if recursive and dir.current_is_dir():
			contents.append_array(get_folder_contents(dir.get_current_dir() + "/" + file, type, recursive))
		else:
			if type != file.get_extension():
				file = dir.get_next()
				continue
			contents.append(dir.get_current_dir() + "/" + file)
		file = dir.get_next()
	return contents

func get_brushes() -> Dictionary[String, String]:
	var folder_contents: Array[String] = get_folder_contents(brush_path, "tres", true)
	var valid_brushes: Dictionary[String, String]
	
	for file_path in folder_contents:
		var resource = load(file_path)
		if resource.get_script().get_global_name() == "BaseBrush":
			valid_brushes[resource.inspector_name] = file_path
	
	return valid_brushes

func get_palettes() -> Dictionary[String, String]:
	var folder_contents: Array[String] = get_folder_contents(palette_path, "tres", true)
	var valid_palettes: Dictionary[String, String]
	
	for file_path in folder_contents:
		var resource = load(file_path)
		if resource.get_script().get_global_name() == "VoxelColorPalette":
			valid_palettes[resource.palette_name] = file_path
			
	return valid_palettes
