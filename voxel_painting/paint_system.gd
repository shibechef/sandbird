extends Node
class_name PaintSystem

var object_selection: ObjectSelectionSystem
var collision_system: CollisionSystem
var palette_manager: ColorPaletteManager
var mesh_system: MeshSystem
var ui_manager: UIManager
var edit_logger: EditLogging
var brush_properties_UI: BrushPropertiesTab

var brush_paths: Dictionary[String, String]
@export var brush_list: Dictionary[String, BaseBrush] 
var current_brush: String
var brush_UI_buttons: Dictionary[String, Button]

var last_selected: String
var last_selected_time: float = 0.0
var last_click_data: Array[Vector3]

func _ready():
	object_selection = get_node("%ObjectSelectionSystem")
	collision_system = get_node("%CollisionSystem")
	palette_manager = get_node("%ColorPaletteManager")
	mesh_system = get_node("%MeshSystem")
	edit_logger = get_node("%EditLogger")
	brush_properties_UI = get_node("%ExtendedBrushSidebarUI").get_node("%BrushProperties")
	call_deferred("late_ready")

func _process(delta):
	last_selected_time += delta

func late_ready():
	ui_manager = get_node("%UIManager")
	ui_manager.update_brush_sidebar(brush_list.values())

func try_click(hold_time: float) -> void:
	if current_brush.is_empty():
		## No brush selected!
		return
	
	var click_data: Array[Vector3] = get_parent().get_node("%WorldClick").get_mouse_world_pos()
	var obj: VoxelObject = object_selection.currently_selected_objects[object_selection.currently_selected_objects.keys()[0]]
	
	if hold_time == 0.0:
		last_click_data = click_data.duplicate()
	
	var selected_colors: Array[PaletteColor] = []
	for color_id in palette_manager.currently_selected_colors:
		selected_colors.append(palette_manager.get_color_from_id(color_id))
	
	var input_data: Dictionary = {
		"hold_time" = hold_time,
		"origin_0" = last_click_data[0],
		"dir_0" = last_click_data[1],
		"origin_1" = click_data[0],
		"dir_1" = click_data[1],
	}
	
	var voxel_diff: Dictionary[Vector3i, VoxelData] = brush_list[current_brush].get_voxels(input_data, obj, selected_colors)
	voxel_diff = obj.get_only_changed(voxel_diff)
	
	obj.change_voxels(voxel_diff)
	obj.consecutive_changes.merge(voxel_diff, true)
	
	last_click_data = click_data

func click_ended() -> void:
	var obj: VoxelObject = object_selection.currently_selected_objects[object_selection.currently_selected_objects.keys()[0]]
	
	var inverted_changes: Dictionary[Vector3i, VoxelData] = get_inverted_diff(obj.previous_grid, obj.consecutive_changes)
	print(obj.consecutive_changes.size(), " ", inverted_changes.size())
	edit_logger.log_edit(EditLogging.EditType.voxel_change, [obj.consecutive_changes, inverted_changes, obj.get_instance_id()])
	obj.consecutive_changes.clear()

func get_inverted_diff(previous_voxels: Dictionary[Vector3i, VoxelData], changes: Dictionary[Vector3i, VoxelData]) -> Dictionary[Vector3i, VoxelData]:
	var inverted_changes: Dictionary[Vector3i, VoxelData]
	for pos in changes:
		if !previous_voxels.has(pos):
			inverted_changes[pos] = null
		else:
			inverted_changes[pos] = previous_voxels[pos]
	return inverted_changes
	
func select_brush(brush: String) -> void:
	brush_properties_UI.fill_properties(brush_list[brush])
	
	## double clicking to close too feels nice to me but maybe auto close is better
	if last_selected_time < .4 and last_selected == brush:
		brush_properties_UI.extend(true)

	last_selected = brush
	last_selected_time = 0.0
	
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

func add_existing_brush(brush: BaseBrush):
	brush_list[brush.named_as] = brush
	ui_manager.update_brush_sidebar(brush_list.values())	

enum PaintingMode{
	basic,
	rail
}
