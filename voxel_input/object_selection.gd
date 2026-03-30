extends Node
class_name ObjectSelectionSystem

var currently_selected_objects: Array[VoxelObject]

var collision_system: CollisionSystem
var camera_system: CameraSystem
var hierarchy: Hierarchy

var col1: Node3D = CSGSphere3D.new()
var col2: Node3D = CSGSphere3D.new()

func _ready():
	camera_system = get_parent().get_parent().get_node("%CameraSystem")
	collision_system = get_node("%CollisionSystem")
	hierarchy = get_node("%Hierarchy")
	add_child(col1)
	add_child(col2)

## testing shitcode
func _process(delta):
	var result: Array[Dictionary]
	if Input.is_action_just_pressed("select"):
		var objs: Dictionary[int, Array]
		for obj in hierarchy.all_objects:
			objs[obj] = [hierarchy.all_objects[obj].position, hierarchy.all_objects[obj].dimensions]
		result = collision_system.get_AABB_line_collisions(camera_system.position, camera_system.get_global_transform().basis.z, objs)
	else:
		return
	
	if !result.is_empty():
		col1.position = result[0]["col_1"]
		if result[0].has("col_2"):
			col2.position = result[0]["col_2"]

	var hit_obj = collision_system.get_first_outline_col(result)
	print(hit_obj)
