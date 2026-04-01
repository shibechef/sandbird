extends Node

@export var camera_system: CameraSystem

func _ready():
	camera_system = get_node("%CameraSystem")

func get_mouse_world_pos() -> Array[Vector3]:
	var mouse_screen_pos = get_viewport().get_mouse_position()
	var mouse_origin = camera_system.project_ray_origin(mouse_screen_pos)
	var mouse_direction = mouse_origin - camera_system.project_position(mouse_screen_pos, 1.0)
	
	return [mouse_origin, mouse_direction]
