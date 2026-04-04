extends Node
class_name ObjectSelectionSystem

var currently_selected_objects: Dictionary[int, VoxelObject]
var highest_priority_selection: int

var collision_system: CollisionSystem
var camera_system: CameraSystem
var hierarchy: Hierarchy

func _ready():
	camera_system = get_parent().get_parent().get_node("%CameraSystem")
	collision_system = get_node("%CollisionSystem")
	hierarchy = get_node("%Hierarchy")
	
func try_click() -> void:
	if !Input.is_action_pressed("select_several") && !Input.is_action_pressed("select_one"):
		deselect_all()
	
	var result: Array[Dictionary]
	var objs: Dictionary[int, Array]
	for obj in hierarchy.all_objects:
		objs[obj] = [hierarchy.all_objects[obj].position, hierarchy.all_objects[obj].dimensions]
	
	var click_data = get_parent().get_node("%WorldClick").get_mouse_world_pos()
	
	result = collision_system.get_AABB_line_collisions(click_data[0], click_data[1], objs)
	
	var hit_obj: int = collision_system.get_first_outline_col(result)
	if hit_obj != 0:
		select_object(hit_obj)

func select_object(id: int) -> void:
	var object = hierarchy.all_objects[id]
	
	if Input.is_action_pressed("select_one") && currently_selected_objects.has(id):
		object.toggle_selection(false)
		currently_selected_objects.erase(id)
		return
		
	highest_priority_selection = id
	object.toggle_selection(true)
	currently_selected_objects[id] = object

func deselect_all() -> void:
	for id in currently_selected_objects:
		currently_selected_objects[id].toggle_selection(false)
	currently_selected_objects.clear()
	highest_priority_selection = 0

func hide_unselected_borders() -> void:
	for id in hierarchy.all_objects:
		if currently_selected_objects.has(id):
			continue
		var obj: VoxelObject = hierarchy.all_objects[id]
		obj.outline_object.hide()

func unhide_all_borders() -> void:
	for id in hierarchy.all_objects:
		var obj: VoxelObject = hierarchy.all_objects[id]
		obj.outline_object.show()
	
