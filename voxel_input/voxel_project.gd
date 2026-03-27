extends Node
class_name VoxelProject

func on_new_project() -> void:
	var scene_preferences: ProjectPreferences = get_node("%ProjectPreferences")
	scene_preferences.on_new_scene()
