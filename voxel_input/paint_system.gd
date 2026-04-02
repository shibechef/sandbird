extends Node
class_name PaintSystem

var object_selection: ObjectSelectionSystem
var collision_system: CollisionSystem

func _ready():
	object_selection = get_node("%ObjectSelectionSystem")
	collision_system = get_node("%CollisionSystem")

func try_click() -> void:
	var position: Vector3 = get_collision_pos()
	print(position)

func get_collision_pos() -> Vector3i:
	var closest_collision: Vector3i
	
	var click_data = get_parent().get_node("%WorldClick").get_mouse_world_pos()
	var result: Array[Dictionary]
	var objs: Dictionary[int, Array]
	for obj in object_selection.currently_selected_objects:
		objs[obj] = [object_selection.currently_selected_objects[obj].position, object_selection.currently_selected_objects[obj].dimensions]
	
	result = collision_system.get_AABB_line_collisions(click_data[0], click_data[1], objs)
	
	## Do voxel looking first
	
	
	
	## Bound box collision if nothing is before it
	var furthest_distance: float = -1.0
	var furthest_point: Vector3
	
	for dict in result:
		if dict.has("distance_2"):
			if dict["distance_2"] > furthest_distance:
				furthest_distance = dict["distance_2"]
				furthest_point = dict["col_2"]
		else:
			if dict["distance_1"] > furthest_distance:
				furthest_distance = dict["distance_1"]
				furthest_point = dict["col_1"]
	
	closest_collision = furthest_point
	
	return closest_collision
	
