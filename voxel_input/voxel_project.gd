extends Node
class_name VoxelProject

@export var project_name: String = "Default"
@export var last_opened_time: Dictionary

func _init():
	last_opened_time = Time.get_datetime_dict_from_system()
	ProjectManager.current_project = self

func on_new_project() -> void:
	var scene_preferences: ProjectPreferences = get_node("%ProjectPreferences")
	scene_preferences.on_new_scene()
