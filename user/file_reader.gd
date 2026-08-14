extends Node

var brush_path: String = "res://user_data/brushes/"
var palette_path: String = "res://user_data/palettes/"
var project_path: String = "res://user_data/projects/"

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
	var dir := DirAccess.open("res://user_data/")
	if !dir.dir_exists("brushes"):
		dir.make_dir("brushes")
		
	var folder_contents: Array[String] = get_folder_contents(brush_path, "tres", true)
	var valid_brushes: Dictionary[String, String]
	
	for file_path in folder_contents:
		var resource = load(file_path)
		if resource is not BaseBrush:
			continue
		
		valid_brushes[resource.named_as] = file_path
	
	return valid_brushes

func get_palettes() -> Dictionary[String, String]:
	var dir := DirAccess.open("res://user_data/")
	if !dir.dir_exists("palettes"):
		dir.make_dir("palettes")
		
	var folder_contents: Array[String] = get_folder_contents(palette_path, "tres", true)
	var valid_palettes: Dictionary[String, String]
	
	for file_path in folder_contents:
		var resource = load(file_path)
		if resource.get_script().get_global_name() != "VoxelColorPalette":
			continue
		
		valid_palettes[resource.palette_name] = file_path
			
	return valid_palettes

func get_projects() -> Dictionary[String, String]:
	var dir := DirAccess.open("res://user_data/")
	if !dir.dir_exists("projects"):
		dir.make_dir("projects")
		
	var folder_contents: Array[String] = get_folder_contents(project_path, "tscn", true)
	var valid_projects: Dictionary[String, String]
	
	for file_path in folder_contents:
		var resource = load(file_path)
		if resource is not PackedScene:
			continue
		
		var scene = resource.instantiate()
		if scene is not VoxelProject:
			continue
		
		valid_projects[scene.project_name] = file_path
		
	return valid_projects

func open_folder_UI(file_path: String):
	file_path = ProjectSettings.globalize_path(file_path)
	OS.shell_open(file_path)
