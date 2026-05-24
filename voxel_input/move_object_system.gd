extends Node
class_name MoveObjectSystem

var current_mouse_move: Vector2 = Vector2.ZERO
var actively_moving: bool = false
var current_mode: InputManager.InteractionMode
var pressed_dirs: Vector3 = Vector3.ONE

var world_click: WorldClick
var object_selection: ObjectSelectionSystem
var edit_logging: EditLogging

var previous_obj_positions: Dictionary[int, Vector3]

func _ready():
	world_click = get_parent().get_node("%WorldClick")
	object_selection = get_node("%ObjectSelectionSystem")
	edit_logging = get_node("%EditLogger")

func _process(delta):
	if !actively_moving:
		return
		
	var offset: Vector3 = get_current_offset()
	var rounded_offset: Vector3i = Vector3i(offset)
	
	## make sure to add lights or whatever here
	if current_mode == InputManager.InteractionMode.object:
		var selected_objs: Dictionary[int, VoxelObject] = object_selection.currently_selected_objects
		for obj_id in selected_objs:
			selected_objs[obj_id].position = previous_obj_positions[obj_id] + Vector3(rounded_offset)

func start_move(mode: InputManager.InteractionMode) -> void:
	current_mode = mode
	actively_moving = true
	
	if current_mode == InputManager.InteractionMode.object:
		var selected_objs: Dictionary[int, VoxelObject] = object_selection.currently_selected_objects
		for obj_id in selected_objs:
			previous_obj_positions[obj_id] = selected_objs[obj_id].position

func finalize_move() -> void:		
	var offset: Vector3 = get_current_offset()
	var rounded_offset: Vector3i = Vector3i(offset)
	
	if current_mode == InputManager.InteractionMode.object:
		var selected_objects: Array[int] = object_selection.currently_selected_objects.keys()
		edit_logging.log_edit(EditLogging.EditType.model_move, [Vector3(rounded_offset), selected_objects])
	
	current_mouse_move = Vector2.ZERO
	actively_moving = false
	pressed_dirs = Vector3.ONE

## factor zoom into this
func get_current_offset() -> Vector3:
	var mouse_data = world_click.get_forwards_pos()
	var dir: Vector3 = mouse_data[1]
	
	var offset: Vector3 = Vector3.ZERO
	offset.x = current_mouse_move.x * sin(dir.z) * pressed_dirs.x
	offset.y = current_mouse_move.y * pressed_dirs.y * pressed_dirs.y
	offset.z = current_mouse_move.x * -sin(dir.x) * pressed_dirs.z
	offset *= UserPreferences.object_grabbing_sensitivity * .2
	return offset

func cancel_move() -> void:
	if current_mode == InputManager.InteractionMode.object:
		var selected_objs: Dictionary[int, VoxelObject] = object_selection.currently_selected_objects
		for obj_id in selected_objs:
			selected_objs[obj_id].position = previous_obj_positions[obj_id]
	
	current_mouse_move = Vector2.ZERO
	actively_moving = false
	pressed_dirs = Vector3.ONE
