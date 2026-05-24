extends Node
class_name PaintSystem

var object_selection: ObjectSelectionSystem
var collision_system: CollisionSystem
var palette_manager: ColorPaletteManager
var mesh_system: MeshSystem
var ui_manager: UI_manager
var edit_logger: EditLogging

var brush_paths: Dictionary[String, String]
@export var brush_list: Dictionary[String, BaseBrush] 
var current_brush: String
var brush_UI_buttons: Dictionary[String, Button]

func _ready():
	object_selection = get_node("%ObjectSelectionSystem")
	collision_system = get_node("%CollisionSystem")
	palette_manager = get_node("%ColorPaletteManager")
	mesh_system = get_node("%MeshSystem")
	edit_logger = get_node("%EditLogger")
	call_deferred("late_ready")

func late_ready():
	ui_manager = get_node("%UI_manager")
	ui_manager.update_brush_sidebar(brush_list.values())

func try_click() -> void:
	if current_brush.is_empty():
		## No brush selected!
		return
	
	var click_data = get_parent().get_node("%WorldClick").get_mouse_world_pos()
	var obj: VoxelObject = object_selection.currently_selected_objects[object_selection.currently_selected_objects.keys()[0]]
	
	var voxel_diff: Dictionary[Vector3i, VoxelData] = brush_list[current_brush].get_voxels(click_data[0], click_data[1], obj)
	voxel_diff = obj.get_only_changed(voxel_diff)
	var previous_voxels: Dictionary[Vector3i, VoxelData] = obj.get_previous(voxel_diff)
		
	edit_logger.log_edit(EditLogging.EditType.voxel_change, [voxel_diff, previous_voxels, obj.get_instance_id()])
	obj.change_voxels(voxel_diff)

func select_brush(brush: String) -> void:
	if current_brush != "":
		brush_UI_buttons[current_brush].set_pressed_no_signal(false)
	
	brush_UI_buttons[brush].set_pressed_no_signal(true)
	current_brush = brush

func add_new_brush():
	var brush_name = "brush 1"
	var n = 1
	while brush_list.has(brush_name):
		n += 1
		brush_name = "brush " + str(n)
	
	var brush: PointBrush = PointBrush.new()
	brush.named_as = brush_name
	brush_list[brush_name] = brush
	
	ui_manager.update_brush_sidebar(brush_list.values())	

enum PaintingMode{
	basic,
	rail
}
