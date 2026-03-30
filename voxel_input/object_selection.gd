extends Node
class_name ObjectSelectionSystem

var currently_selected_objects: Array[VoxelObject]

var collision_system: CollisionSystem
var camera_system: CameraSystem

var col1: Node3D = CSGSphere3D.new()
var col2: Node3D = CSGSphere3D.new()

func _ready():
	camera_system = get_parent().get_parent().get_node("%CameraSystem")
	collision_system = get_node("%CollisionSystem")
	add_child(col1)
	add_child(col2)

func _process(delta):
	var result: Array[Dictionary]
	if Input.is_action_just_pressed("select"):
		result = collision_system.get_AABB_line_collisions(camera_system.position, camera_system.get_global_transform().basis.z, {0: [Vector3(16, 4, 8), Vector3(32, 8, 16)]})
	if !result.is_empty():
		col1.position = result[0]["col_1"]
		col2.position = result[0]["col_2"]
