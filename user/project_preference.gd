extends Node
class_name ProjectPreferences

@export var default_object_size: Vector3i

func on_new_scene() -> void:
	default_object_size = UserPrefs.default_object_size
