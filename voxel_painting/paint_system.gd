extends Node
class_name PaintSystem

var object_selection: ObjectSelectionSystem
var collision_system: CollisionSystem
var palette_manager: ColorPaletteManager
var mesh_system: MeshSystem
var brush_sidebar: BrushSidebarUI

var brush_paths: Dictionary[String, String]
@export var brush_list: Dictionary[String, BaseBrush] 
var current_brush: String

func _ready():
	object_selection = get_node("%ObjectSelectionSystem")
	collision_system = get_node("%CollisionSystem")
	palette_manager = get_node("%ColorPaletteManager")
	mesh_system = get_node("%MeshSystem")
	call_deferred("late_ready")

func late_ready():
	brush_sidebar = get_node("%UI_manager").get_node("BrushSidebarUI")
	brush_sidebar.fill_list(brush_list.values())

func try_click() -> void:
	if current_brush.is_empty():
		## No brush selected!
		return
	
	var click_data = get_parent().get_node("%WorldClick").get_mouse_world_pos()
	var obj: VoxelObject = object_selection.currently_selected_objects[object_selection.currently_selected_objects.keys()[0]]
	var voxel_diff: Dictionary[Vector3i, VoxelData] = brush_list[current_brush].get_voxels(click_data[0], click_data[1], obj)
	obj.change_voxels(voxel_diff)

func select_brush(brush: String) -> void:
	current_brush = brush

enum PaintingMode{
	basic,
	rail
}
